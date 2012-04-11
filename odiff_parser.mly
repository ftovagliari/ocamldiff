/*********************************************************************************/
/*                OCamldiff                                                      */
/*                                                                               */
/*    Copyright (C) 2004-2012 Institut National de Recherche en Informatique     */
/*    et en Automatique. All rights reserved.                                    */
/*                                                                               */
/*    This program is free software; you can redistribute it and/or modify       */
/*    it under the terms of the GNU Lesser General Public License version        */
/*    3 as published by the Free Software Foundation.                            */
/*                                                                               */
/*    This program is distributed in the hope that it will be useful,            */
/*    but WITHOUT ANY WARRANTY; without even the implied warranty of             */
/*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              */
/*    GNU Library General Public License for more details.                       */
/*                                                                               */
/*    You should have received a copy of the GNU Lesser General Public           */
/*    License along with this program; if not, write to the Free Software        */
/*    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA                   */
/*    02111-1307  USA                                                            */
/*                                                                               */
/*    Contact: Maxence.Guesdon@inria.fr                                          */
/*                                                                               */
/*                                                                               */
/*********************************************************************************/

%{
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
open Odiff_types

let print_DEBUG s = print_string s; print_newline ()
%}

%token <int> IndexOne
%token <int*int> IndexMany
%token ADD
%token DELETE
%token CHANGE
%token SEP
%token EOF
%token <string> AddedString
%token <string> DeletedString

/* Start Symbols */
%start main 
%type <Odiff_types.diffs> main

%%
main:
  diffs EOF { $1 }
| EOF { [] }
;

diffs:
  diff { [$1] }
| diff diffs { $1 :: $2 }
;

diff:
  index ADD index added_text { Add ($1, $3, $4) }
| index DELETE index deleted_text { Delete ($1, $3, $4) }
| index CHANGE index deleted_text SEP added_text { Change ($1, $4, $3, $6) }
;

index:
    IndexOne { One $1 }
| IndexMany { Many (fst $1, snd $1) }
;

added_text:
    AddedString { $1 }
| AddedString added_text { $1 ^"\n"^ $2 }
;

deleted_text:
    DeletedString { $1 }
| DeletedString deleted_text { $1 ^"\n"^ $2 }
;


%% 
