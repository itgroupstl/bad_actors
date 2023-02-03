# Bad Actors
Find all the ip adresses that have repeat offenses according to the NGINX or Apache access logs. <br />
The only requirement is that the log files have the ip address as the first field of every log entry.

Uses a threshold number of your choosing to match against a list of offending http response codes that increments per ip address.


<strong>Installation</strong> <br />
(Optional) Edit the script file with your threshold and http response code parameters <br />
Making sure it is executable. (sudo chmod +x bad_actors.sh) <br />
Run it. (sudo ./bad_actors.sh) <br />
