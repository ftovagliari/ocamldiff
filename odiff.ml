(*********************************************************************************)
(*                Cameleon                                                       *)
(*                                                                               *)
(*    Copyright (C) 2004-2011 Institut National de Recherche en Informatique     *)
(*    et en Automatique. All rights reserved.                                    *)
(*                                                                               *)
(*    This program is free software; you can redistribute it and/or modify       *)
(*    it under the terms of the GNU Library General Public License as            *)
(*    published by the Free Software Foundation; either version 2 of the         *)
(*    License, or any later version.                                             *)
(*                                                                               *)
(*    This program is distributed in the hope that it will be useful,            *)
(*    but WITHOUT ANY WARRANTY; without even the implied warranty of             *)
(*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *)
(*    GNU Library General Public License for more details.                       *)
(*                                                                               *)
(*    You should have received a copy of the GNU Library General Public          *)
(*    License along with this program; if not, write to the Free Software        *)
(*    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA                   *)
(*    02111-1307  USA                                                            *)
(*                                                                               *)
(*    Contact: Maxence.Guesdon@inria.fr                                          *)
(*                                                                               *)
(*********************************************************************************)

(* $Id$ *)


type index = Odiff_types.index =
  | One of int
  | Many of int * int

type diff = Odiff_types.diff =
  | Add of index * index * string
  | Delete of index * index * string
  | Change of index * string * index * string

type diffs = diff list

let parse_from_lexbuf lex =
  Odiff_lexer.line := 0;
  try
    Odiff_parser.main Odiff_lexer.main lex
  with
    Parsing.Parse_error ->
      raise (Failure ("Parse error line "^(string_of_int !Odiff_lexer.line)))
  | e ->
      let s = Printf.sprintf "Line %d: %s"
          !Odiff_lexer.line (Printexc.to_string e)
      in
      failwith s

(*c==v=[String.split_string]=1.0====*)
let split_string s chars =
  let len = String.length s in
  let rec iter acc pos =
    if pos >= len then
      match acc with
        "" -> []
      | _ -> [acc]
    else
      if List.mem s.[pos] chars then
        match acc with
          "" -> iter "" (pos + 1)
        | _ -> acc :: (iter "" (pos + 1))
      else
        iter (Printf.sprintf "%s%c" acc s.[pos]) (pos + 1)
  in
  iter "" 0
(*/c==v=[String.split_string]=1.0====*)

let string_of_index ?(offset=0) = function
    One n -> string_of_int (offset+n)
  | Many (n,m) -> Printf.sprintf "%d,%d" (offset+n) (offset+m)

let prepend_lines s txt =
  let l = split_string txt ['\n'] in
(*  String.concat "\n" (List.map (fun s1 -> s ^ s1) l)*)
  String.concat "\n" (List.map ((^) s) l)

let string_of_diff ?offset = function
    Add (i1,i2,s) ->
      let i1 = string_of_index ?offset i1
      and i2 = string_of_index ?offset i2 in
      let txt = prepend_lines "> " s in
      Printf.sprintf "%sa%s\n%s" i1 i2 txt
  | Delete (i1,i2,s) ->
      let i1 = string_of_index ?offset i1
      and i2 = string_of_index ?offset i2 in
      let txt = prepend_lines "< " s in
      Printf.sprintf "%sd%s\n%s" i1 i2 txt
  | Change (i1,s1,i2,s2) ->
      let i1 = string_of_index ?offset i1
      and i2 = string_of_index ?offset i2 in
      let txt1 = prepend_lines "< " s1 in
      let txt2 = prepend_lines "> " s2 in
      Printf.sprintf "%sc%s\n%s\n---\n%s"
        i1 i2 txt1 txt2

let string_of_diffs ?offset l =
  (String.concat "\n" (List.map (string_of_diff ?offset) l))^"\n"

let print_diffs oc ?offset l =
  Printf.fprintf oc "%s" (string_of_diffs ?offset l)

let from_string s =
  parse_from_lexbuf (Lexing.from_string s)

let from_channel ic =
  parse_from_lexbuf (Lexing.from_channel ic)

let from_file s =
  try from_channel (open_in s)
  with Sys_error s -> failwith s

(*c==v=[Misc.try_finalize]=1.0====*)
let try_finalize f x finally y =
  let res =
    try f x
    with exn -> finally y; raise exn
  in
  finally y;
  res
(*/c==v=[Misc.try_finalize]=1.0====*)

(*c==v=[File.file_of_string]=1.1====*)
let file_of_string ~file s =
  let oc = open_out file in
  output_string oc s;
  close_out oc
(*/c==v=[File.file_of_string]=1.1====*)

let files_diffs f1 f2 =
  let com = Printf.sprintf "diff %s %s"
      (Filename.quote f1) (Filename.quote f2)
  in
  let ic =
    try Unix.open_process_in com
    with
      Unix.Unix_error (e,s1,s2) ->
        failwith (Printf.sprintf "%s: %s %s" (Unix.error_message e) s1 s2)
  in
  let final () = try ignore(Unix.close_process_in ic) with _ -> () in
  try_finalize from_channel ic final ()

let strings_diffs s1 s2 =
  let (f1, f2) =
    try
      let f1 = Filename.temp_file "odiff" ".txt" in
      file_of_string ~file: f1 s1;
      let f2 = Filename.temp_file "odiff" ".txt" in
      file_of_string ~file: f2 s2;
      (f1,f2)
    with Sys_error s -> failwith s
  in
  let final () =
    (try Sys.remove f1 with _ -> ());
    (try Sys.remove f2 with _ -> ())
  in
  try_finalize (files_diffs f1) f2 final ()
