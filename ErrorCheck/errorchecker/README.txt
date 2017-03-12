Maven has been run on the following Maven source tree

  $ tree
  .
  +-- dist.xml
  +-- pom.xml
  +-- README.txt
  +-- src
      +-- main
          +-- resources
              +-- docs
                  +-- NOTES.txt
              +-- scripts
                  +-- errchecker


with the command 

  $ mvn  clean package assembly:single

and has produced the file errorchecker.tar.gz that contains the following 
directories and files:

  $ tar ztvf target/errorchecker.tar.gz 
  drwxr-xr-x  0 gabriel staff       0 Mar 30 14:26 errorchecker/bin/
  -rw-r--r--  0 gabriel staff      17 Mar 30 14:26 errorchecker/bin/errchecker
  drwxr-xr-x  0 gabriel staff       0 Mar 30 11:05 errorchecker/docs/
  -rw-r--r--  0 gabriel staff      12 Mar 30 11:05 errorchecker/docs/NOTES.txt
  -rw-r--r--  0 gabriel staff     832 Mar 30 14:41 errorchecker/dist.xml
  -rw-r--r--  0 gabriel staff    1323 Mar 30 19:21 errorchecker/pom.xml
  -rw-r--r--  0 gabriel staff     286 Mar 30 19:32 errorchecker/README.txt
