# Bad Actors
Find all the ip adresses that have repeat offenses according the NGINX access logs.

Uses a threshold number of your choosing to match against a list of offending http response codes that increments per ip address.


<strong>Installation</strong>
Edit the script file with your threshold and http response code parameters
Making sure it is executable. (sudo chmod +x badactors.sh)
Run it. (sudo ./badactors.sh)
