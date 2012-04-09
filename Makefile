#################################################################################
#                OCamldiff                                                      #
#                                                                               #
#    Copyright (C) 2004-2012 Institut National de Recherche en Informatique     #
#    et en Automatique. All rights reserved.                                    #
#                                                                               #
#    This program is free software; you can redistribute it and/or modify       #
#    it under the terms of the GNU Lesser General Public License version        #
#    3 as published by the Free Software Foundation.                            #
#                                                                               #
#    This program is distributed in the hope that it will be useful,            #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of             #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              #
#    GNU Library General Public License for more details.                       #
#                                                                               #
#    You should have received a copy of the GNU Library General Public          #
#    License along with this program; if not, write to the Free Software        #
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA                   #
#    02111-1307  USA                                                            #
#                                                                               #
#    Contact: Maxence.Guesdon@inria.fr                                          #
#                                                                               #
#                                                                               #
#################################################################################

#
VERSION=1.0

PACKAGES=unix,lablgtk2

OF_FLAGS=-package $(PACKAGES)
OCAMLFIND=ocamlfind
OCAMLLEX=ocamllex
OCAMLYACC=ocamlyacc
OCAML_COMPFLAGS= -annot
OCAMLC=$(OCAMLFIND) ocamlc $(OF_FLAGS) $(OCAML_COMPFLAGS)
OCAMLOPT=$(OCAMLFIND) ocamlopt $(OF_FLAGS) $(OCAML_COMFLAGS)
OCAMLDOC=$(OCAMLFIND) ocamldoc $(OF_FLAGS)
OCAMLDEP=ocamldep

all: byte opt
byte: odiff.cma odiff_gtk.cma
opt: odiff.cmxa odiff_gtk.cmxa

CMOFILES= \
	odiff_types.cmo \
	odiff_parser.cmo \
	odiff_lexer.cmo \
	odiff.cmo

CMXFILES=$(CMOFILES:.cmo=.cmx)
CMIFILES=$(CMOFILES:.cmo=.cmi)

GTK_CMOFILES= \
	odiff_messages.cmo \
	odiff_merge.cmo \
	odiff_box.cmo \
	odiff_gtk.cmo

GTK_CMXFILES=$(GTK_CMOFILES:.cmo=.cmx)
GTK_CMIFILES=$(GTK_CMOFILES:.cmo=.cmi)

odiff.cma: $(CMIFILES) $(CMOFILES)
	$(OCAMLC) -o $@ -a $(CMOFILES)

odiff.cmxa: $(CMIFILES) $(CMXFILES)
	$(OCAMLOPT) -o $@ -a $(CMXFILES)

odiff_gtk.cma: odiff.cma $(GTK_CMIFILES) $(GTK_CMOFILES)
	$(OCAMLC) -o $@ -a $(GTK_CMOFILES)

odiff_gtk.cmxa: odiff.cmxa $(GTK_CMIFILES) $(GTK_CMXFILES)
	$(OCAMLOPT) -o $@ -a $(GTK_CMXFILES)

.PHONY: doc depend

doc: all
	mkdir -p html
	$(OCAMLDOC) -t OCamldiff -d html -html odiff.mli odiff_gtk.mli

webdoc: doc
	mkdir -p ../ocamldiff-gh-pages/refdoc
	cp html/* ../ocamldiff-gh-pages/refdoc/
	cp web/index.html web/style.css ../ocamldiff-gh-pages/

.depend depend:
	$(OCAMLDEP) odiff*.ml odiff*.mli > .depend

odifftest: odiff.cmxa odiff_test.ml
	$(OCAMLOPT) -linkpkg -o $@ $^

test: odifftest
	@./rsstest test.rss > t.rss
	@./rsstest t.rss > t2.rss
	@((diff t.rss t2.rss && echo OK) || echo "t.rss and t2.rss differ")

# installation :
################
install: byte opt
	$(OCAMLFIND) install diff META LICENSE \
	odiff.cmi odiff.cma odiff.cmxa odiff.a \
	odiff_gtk.cmi odiff_gtk.cma odiff_gtk.cmxa odiff_gtk.a

uninstall:
	ocamlfind remove diff

# archive :
###########
archive:
	git archive --prefix=ocamldiff-$(VERSION)/ HEAD | gzip > ../ocamldiff-gh-pages/ocamldiff-$(VERSION).tar.gz

# Cleaning :
############
clean:
	rm -f *.cm* *.a *.annot *.o odiff_lexer.ml odiff_parser.ml odiff_parser.mli

# headers :
###########
HEADFILES=Makefile *.ml *.mli *.mly *.mll
.PHONY: headers noheaders
headers:
	headache -h header -c .headache_config $(HEADFILES)

noheaders:
	headache -r -c .headache_config $(HEADFILES)

# generic rules :
#################
.SUFFIXES: .mli .ml .cmi .cmo .cmx .mll .mly .sch .html .mail

%.cmi:%.mli
	$(OCAMLC) -c $<

%.cmo:%.ml
	$(OCAMLC) -c $<

%.cmi %.cmo:%.ml
	$(OCAMLC) -c $<

%.cmx %.o:%.ml
	$(OCAMLOPT) -c $<

%.mli %.ml: %.mly
	$(OCAMLYACC) $<

%.ml: %.mll
	$(OCAMLLEX) $<


include .depend

