(*********************************************************************************)
(*                OCamldiff                                                      *)
(*                                                                               *)
(*    Copyright (C) 2004-2012 Institut National de Recherche en Informatique     *)
(*    et en Automatique. All rights reserved.                                    *)
(*                                                                               *)
(*    This program is free software; you can redistribute it and/or modify       *)
(*    it under the terms of the GNU Lesser General Public License version        *)
(*    3 as published by the Free Software Foundation.                            *)
(*                                                                               *)
(*    This program is distributed in the hope that it will be useful,            *)
(*    but WITHOUT ANY WARRANTY; without even the implied warranty of             *)
(*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *)
(*    GNU Library General Public License for more details.                       *)
(*                                                                               *)
(*    You should have received a copy of the GNU Lesser General Public           *)
(*    License along with this program; if not, write to the Free Software        *)
(*    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA                   *)
(*    02111-1307  USA                                                            *)
(*                                                                               *)
(*    Contact: Maxence.Guesdon@inria.fr                                          *)
(*                                                                               *)
(*                                                                               *)
(*********************************************************************************)

{
(***********************************************************************)
(*                             OCamlcvs                                *)
(*                                                                     *)
(*            Maxence Guesdon, projet Cristal, INRIA Rocquencourt      *)
(*                                                                     *)
(*  Copyright 2001 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the GNU General Public License version 2.       *)
(*                                                                     *)
(***********************************************************************)

(** The lexer for string to retrieve differences. *)

open Lexing
open Odiff_parser

let print_DEBUG s = () (* print_string s; print_newline () *)
let line = ref 0
}

let blank = [' ' '\013' '\009' '\012']
let any = [^'\n']*

rule main = parse
| ("\\ No newline at end of file"(any))
    {
      main lexbuf
    }
| '\n'
    {
      incr line ;
      main lexbuf
    }
| ['0'-'9']+','['0'-'9']+
    {
      try
	let s = Lexing.lexeme lexbuf in
	print_DEBUG s ;
	let n = String.index s ',' in
	let s1 = String.sub s 0 n in
	let s2 = String.sub s (n+1) ((String.length s) - n - 1) in
	IndexMany (int_of_string s1, int_of_string s2)
      with
	Not_found ->
	  raise (Failure "zarbi")
    }
| ['0'-'9']+
    {
      let s = Lexing.lexeme lexbuf in
      print_DEBUG s ;
      IndexOne (int_of_string s) }
| ("< "(any))
    {
      let s = Lexing.lexeme lexbuf in
      print_DEBUG s ;
      DeletedString (String.sub s 2 ((String.length s) -2))
    }

| ("> "(any))
    {
      let s = Lexing.lexeme lexbuf in
      print_DEBUG s ;
      AddedString (String.sub s 2 ((String.length s) -2))
    }

| 'a'
    {
      print_DEBUG "a" ;
      ADD
    }
| 'd'
    {
      print_DEBUG "d" ;
      DELETE
    }
| 'c'
    {
      print_DEBUG "c" ;
      CHANGE
    }

| eof
    { EOF }

| "---"
    { SEP }
