@echo off 
net use x: /delete
net use x: \\server\share\ /persistent:yes 

