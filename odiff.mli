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

(** Computing differences. *)

(** {2 Representation of differences} *)

(** Index in a file or string. *)
type index = Odiff_types.index =
  | One of int (** one line *)
  | Many of int * int (** many lines, we have the first and the last *)

(** Representation of one difference. *)
type diff = Odiff_types.diff =
  | Add of index * index * string
        (** for <index>a<index> and the added text *)
  | Delete of index * index * string
        (** for <index>d<index> and the deleted text *)
  | Change of index * string * index * string
        (** for <index>c<index> and the deleted and added texts *)

(** Differences between two texts. *)
type diffs = diff list

(** {2 Printing differences} *)

(** @param offset is added to line numbers (can be useful, like in caml-get!). Default is 0. *)
val string_of_diff : ?offset: int -> diff -> string
val string_of_diffs : ?offset: int -> diffs -> string
val print_diffs : out_channel -> ?offset: int -> diffs -> unit

(** {2 Parsing differences} *)

(** Return the list of differences from a string generated string.
   @raise Failure if an error occurs.
*)
val from_string : string -> diffs

(** Same as {!Odiff.from_string} but read from the given in_channel. *)
val from_channel : in_channel -> diffs

(** Same as {!Odiff.from_string} but read from the given file. *)
val from_file : string -> diffs

(** {2 Computing differences} *)

(** [files_diffs file1 file2] runs the [diff] command on
   the given files and returns its parsed output.
   @raise Failure if an error occurs.*)
val files_diffs : string -> string -> diffs

(** Same as {!Odiff.files_diffs} but on strings. The two strings
   are put in two files to run the [diff] command. The files
   are removed before returning the result.
   @raise Failure if an error occurs.
*)
val strings_diffs : string -> string -> diffs
