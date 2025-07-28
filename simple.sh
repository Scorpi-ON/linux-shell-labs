#!/usr/bin/sh

function bp() {
	ps -eo user,pid,time,cmd --sort=-time | head -n $(( $1 + 1 ))
}

function ll() {
	ls -l $1 | tail -n +2 | awk '{ print $3 }' | sort -u
}

function lr() {
	ps -u root -o pid,start,time,cmd --sort=-start | head -n $(( $1 + 1 ))
}

function rl() {
	ls -lh $1 --time=creation --time-style +%d.%m.%y | grep "^-.*$( date +%d.%m.%y ).*"
}

function ml() { 
	ls -lh $1 | grep '^-' | sort -rnk2 | head -n $2 
}

function mp() {
	ps h -eo lstart -D %d.%m.%y | grep $1 | wc -l 
}

function bf() { ls -lhS $1 | grep '^-' | head -n $2; }
function fm() { ls -l $1 | grep -c '^drwxrwxrwx'; }
function lx() { ls -lh $1 | grep '^-rwx------'; }
function npu() { ps -o stat -u $1 | grep -c '^T'; }
function nx() { ls -l $1 | grep -c '^-.*x.*\s'; }
function pt() { ps ht $1 | wc -l; }
function pu() { ps h -u $1 | wc -l; }
function rc() { ps -u $1 | head -n 6; }

alias cu="w -h | wc -l"
alias tu="echo $(( $( who | wc -l ) - 1 ))"
