
```bash
./create_instance.sh ihec-processing-2 som-encode-roadmap ~/.ssh/roadmap-caper-server.json -m c2d-highcpu-8 -b 400GB gs://ihec-output/test
./create_instance.sh ihec-processing-3 som-encode-roadmap ~/.ssh/roadmap-caper-server.json -m c2d-highcpu-8 -b 400GB gs://ihec-output/test
./create_instance.sh ihec-processing-4 som-encode-roadmap ~/.ssh/roadmap-caper-server.json -m c2d-highcpu-8 -b 400GB gs://ihec-output/test

gcloud beta compute ssh --zone us-central1-a ihec-processing-2 --project som-encode-roadmap
gcloud beta compute ssh --zone us-central1-a ihec-processing-3 --project som-encode-roadmap
gcloud beta compute ssh --zone us-central1-a ihec-processing-4 --project som-encode-roadmap
```

```bash
sudo su
mkdir -p /data/code/ && cd /data/code/
chmod 777 -R .
sudo setfacl -R -d -m u::rwX .
sudo setfacl -R -d -m g::rwX .
sudo setfacl -R -d -m o::rwX .

sudo apt-get install trimmomatic -y # version 39
sudo apt-get install samtools python3-deeptools -y

# install singularity on Ubuntu 20.04
# See https://neuro.debian.net/install_pkg.html?p=singularity-container for other Ubuntu OS
wget -O- http://neuro.debian.net/lists/focal.us-ca.full | sudo tee /etc/apt/sources.list.d/neurodebian.sources.list
sudo apt-key adv --recv-keys --keyserver hkps://keyserver.ubuntu.com 0xA5D32F012649A5A9
sudo apt-get update && sudo apt-get install singularity-container -y
exit
```

```bash
cd /data/code/
git clone https://github.com/ENCODE-DCC/ihec-processing
cd ihec-processing
./install.sh
```

```
cd /data/code/ihec-processing/postprocess

./postprocess_gs.sh gs://ihec-output/caper_out/chip/305023e2-7a40-4f34-97b0-bc3360519dbb gs://ihec-postprocessed-output/test/server2
```

