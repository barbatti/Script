LIBNAME=spec.a
PROG=specrgb

SRCDIR=./src
LIBDIR=./lib

LIBNAME=spec.a

CC=gcc
CFLAGS= -O3 -g -Wall -Wextra -pedantic
LFLAGS=-lm

SOURCE=${SRCDIR}/specrgb.c
HEADERS=${SRCDIR}/specrgb.h

all: spec.a ${PROG}

spec.a: ${SRCDIR}/spec.c
	${CC} ${CFLAGS} -c -o ${LIBDIR}/${LIBNAME} ${LFLAGS} ${SRCDIR}/spec.c 

${PROG}: spec.a ${SOURCE} ${HEADERS}
	${CC} ${CFLAGS} -o ${PROG} ${LFLAGS} ${LIBDIR}/${LIBNAME} ${SOURCE}


clean:
	rm ${LIBDIR}/${LIBNAME} ${PROG}
