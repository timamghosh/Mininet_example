sudo docker pull timam91/mn-ryu:demo

sudo docker run --privileged -it  -v $(pwd)/ryu_logs:/logs -p 5530-5540:5530-5540  timam91/mn-ryu:demo

try to access 127.0.0.1:55<33/34/35>/home/ for your browser
