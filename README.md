Dependencies :
  - ocaml
  - menhir (opam install menhir)
  - yojson (opam install yojson)
  - dune (opam install dune)
  - gcc
  - G.js (nodejs)

This project is still in development !
Not all c code will work as i need to implement more assembly instructions

To use the project, first build it using : dune build 

Then, write some code in code.c and compile it using the following command : 

gcc -fno-stack-protector -fno-asynchronous-unwind-tables -fomit-frame-pointer -fcf-protection=none -m32 -S code.c

Then use this command : dune exec bin/main.exe

And finally use this command : node main.js