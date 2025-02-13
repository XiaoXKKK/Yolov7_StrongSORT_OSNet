#!/bin/bash

set +e


# start from clean slate
for i in data.zip MOT16.zip
do
	zip -T $i
	if [ $? -eq 0 ]
	then
		echo 'zip is ok'

	else
		echo 'zip corrupted, deleting'
		rm -rf $i
	fi
done


# create output folder if it doesn't exist
if [ ! -d ./inference/output ]
then
	mkdir -p ./inference/output
	echo 'inference output folder created'
fi



# clone evaluation repo if it does not exist
if [ ! -d ./MOT16_eval/TrackEval ]
then
	echo 'Cloning official MOT16 evaluation repo'
	git clone https://github.com/JonathonLuiten/TrackEval ./MOT16_eval/TrackEval
	# download quick start data folder if it does not exist
	if [ ! -d ./MOT16_eval/TrackEval/data ]
	then
		# download data
		wget -nc https://omnomnom.vision.rwth-aachen.de/data/TrackEval/data.zip -O ./data.zip
		# unzip
		unzip -q ./data.zip -d ./MOT16_eval/TrackEval/
		# delete zip
		#rm data.zip
	fi
fi


# create MOT16 folder if it doesn't exist
if [ ! -d ./MOT16_eval/TrackEval/data/MOT16 ]
then
	mkdir -p ./MOT16_eval/TrackEval/data/MOT16
fi


# if MOT16 data not unziped, then download, unzip and lastly remove zip MOT16 data
if [[ ! -d ./MOT16_eval/TrackEval/data/MOT16/train ]] && [[ ! -d ./MOT16_eval/TrackEval/data/MOT16/test ]]
then
	# download data
	wget -nc https://motchallenge.net/data/MOT16.zip -O ./MOT16.zip
	# unzip
    unzip -q MOT16.zip -d ./MOT16_eval/TrackEval/data/MOT16/
	# delete zip
	#rm MOT16.zip
fi


# create folder to place tracking results for this method
mkdir -p ./MOT16_eval/TrackEval/data/trackers/mot_challenge/MOT16-train/yolov7_strongsort/data/

# inference on 4 MOT16 video sequences at the same time
# suits a 4GB GRAM GPU, feel free to increase if you have more memory
N=4

# generate tracking results for each sequence
for i in MOT16-02 MOT16-04 MOT16-05 MOT16-09 MOT16-10 MOT16-11 MOT16-13
do
	(
		# change name to inference source so that each thread write to its own .txt file
		if [ ! -d ./MOT16_eval/TrackEval/data/MOT16/train/$i/$i ]
		then
			mv ./MOT16_eval/TrackEval/data/MOT16/train/$i/img1/ ./MOT16_eval/TrackEval/data/MOT16/train/$i/$i
		fi
		# run inference on sequence frames
		python3 track.py --source ./MOT16_eval/TrackEval/data/MOT16/train/$i/$i --save-txt --classes 0 --exist-ok --imgsz 1280
	    # move generated results to evaluation repo
	) &
	# https://unix.stackexchange.com/questions/103920/parallelize-a-bash-for-loop
	# allow to execute up to $N jobs in parallel
    if [[ $(jobs -r -p | wc -l) -ge $N ]]
	then
        # now there are $N jobs already running, so wait here for any job
        # to be finished so there is a place to start next one.
        wait -n
    fi
done

# no more jobs to be started but wait for pending jobs
# (all need to be finished)
wait
echo "Inference on all MOT16 sequences DONE"

echo "Moving data from experiment folder to MOT16"
mv ./runs/track/exp/* \
   ./MOT16_eval/TrackEval/data/trackers/mot_challenge/MOT16-train/yolov7_strongsort/data/

# run the evaluation
python ./MOT16_eval/TrackEval/scripts/run_mot_challenge.py --BENCHMARK MOT16 \
 --TRACKERS_TO_EVAL yolov7_strongsort --SPLIT_TO_EVAL train --METRICS CLEAR Identity \
 --USE_PARALLEL False --NUM_PARALLEL_CORES 4
