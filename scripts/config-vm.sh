sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1
sudo apt-get update
sudo apt-get install -y python3-pip
sudo -H pip3 install --upgrade pip
pip3 install jupyter
pip3 install matplotlib tensorflow-gpu==2.10.0
pip3 install azure-ai-ml==1.2.0 azure-identity==1.12.0
jupyter notebook

#EOF