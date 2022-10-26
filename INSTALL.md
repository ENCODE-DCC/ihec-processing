## Installation


Skip this step if you've created a server instance with Caper's GCP startup script. Install Caper and configure Caper for GCP. Follow instrutions in Caper's conf `~/.caper/default.conf` (or `/opt/caper/default.conf`).
```bash
$ pip install caper
$ caper init gcp
```

Install dependencies.
```bash
sudo apt-get install trimmomatic -y
sudo apt-get install samtools python-deeptools -y

wget -O- http://neuro.debian.net/lists/focal.us-ca.full | sudo tee /etc/apt/sources.list.d/neurodebian.sources.list
sudo apt-key adv --recv-keys --keyserver hkps://keyserver.ubuntu.com 0xA5D32F012649A5A9 -y
sudo apt-get update && sudo apt-get install singularity-container -y
```

And then run `install.sh`.

