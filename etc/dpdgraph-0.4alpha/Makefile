#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#            This file is part of the DpdGraph tools.
#  Copyright (C) 2009-2013 Anne Pacalet (Anne.Pacalet@free.fr)
#                ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#      This file is distributed under the terms of the 
#       GNU Lesser General Public License Version 2.1
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.SUFFIXES:

ECHO=@echo
ECHO_CIBLE = $(ECHO) "   * build $@"

PRE=dpd

NAME=dpdgraph
VERSION=$(shell cat VERSION)

COQEXE=./coqthmdep
DPD2DOT=./dpd2dot

ifndef MAKE_PUB
OCAMLLIBDIR := $(shell ocamlc -where)
endif # MAKE_PUB

# TODO: this should probably be configured. This is the OPAM structure.
ifeq ($(wildcard $(OCAMLLIBDIR)/ocamlgraph),) 
  ifeq ($(wildcard $(OCAMLLIBDIR)/../ocamlgraph),) 
     INCLUDES = -I +ocamlgraph
  else
    INCLUDES = -I $(OCAMLLIBDIR)/../ocamlgraph
  endif
else 
  INCLUDES = -I $(OCAMLLIBDIR)/ocamlgraph
endif

all : $(COQEXE) $(DPD2DOT)

DISTRIBUTED = $(PRE)_compute.ml $(PRE)_dot.ml \
	 $(PRE)_parse.mly  $(PRE)_lex.mll $(PRE).ml

ML_ALL = version.ml $(PRE)_compute.ml $(PRE)_dot.ml \
	 $(PRE)_parse.ml  $(PRE)_lex.ml $(PRE).ml
CMOS=$(ML_ALL:%.ml=%.cmo)
CMXS=$(ML_ALL:%.ml=%.cmx)

COQDEP=ocamldep

OCAMLFLAGS =  -w Ael -warn-error -g -dtypes $(INCLUDES) -c
OCAMLOPTFLAGS = -c

COQEXTFILES=searchdepend.ml4 graphdepend.ml4

GENERATED+=$(COQEXTFILES:%.ml4=%.o) $(COQEXTFILES:%.ml4=%.cmx)

DISTRIBUTED+=$(COQEXTFILES)
DISTRIBUTED+=Make

$(COQEXE) : Make_coq $(COQEXTFILES)
	$(ECHO_CIBLE)
	$(MAKE) -f $< $@

Make_coq : Make
	$(ECHO_CIBLE)
	coq_makefile -f $< > $@

GENERATED+= Make_coq

version.ml : VERSION
	$(ECHO_CIBLE)
	$(ECHO) "(* This file is generated by Makefile. Do not modify. *)" > $@
	$(ECHO) "let version = \""$(VERSION)"\"" >> $@

GENERATED+=version.ml

$(DPD2DOT) : $(CMOS)
	$(ECHO_CIBLE)
	ocamlc -g $(INCLUDES) -o $@ graph.cma $(CMOS)

%.cmo : %.ml
	$(ECHO_CIBLE)
	ocamlc $(OCAMLFLAGS) $<

%.cmx : %.ml
	$(ECHO_CIBLE)
	ocamlopt $(OPTPACKFLAGS) $(OCAMLOPTFLAGS) $<

%.cmi : %.mli
	$(ECHO_CIBLE)
	ocamlc $(OCAMLFLAGS) $<

%.ml : %.mll
	$(ECHO_CIBLE)
	ocamllex $<

GENERATED+=$(PRE)_lex.ml 

%.ml : %.mly
	$(ECHO_CIBLE)
	ocamlyacc $<

GENERATED+=$(PRE)_parse.ml $(PRE)_parse.mli

depend: .depend

.depend : $(ML_ALL) 
	$(ECHO_CIBLE)
	ocamldep $(ML_ALL) *.mli > $@

ifndef MAKE_PUB
include .depend
endif # MAKE_PUB

#-------------------------------------------------------------------------------
TESTDIR=tests
TESTS_SRC=$(TESTDIR)/Morph.v $(TESTDIR)/Test.v \
	  $(TESTDIR)/Morph.cmd $(TESTDIR)/Test.cmd $(TESTDIR)/search.cmd
TESTS_DPD=$(TESTDIR)/graph.dpd $(TESTDIR)/graph2.dpd \
	  $(TESTDIR)/Morph.dpd $(TESTDIR)/Morph_rw.dpd
TESTS_DOT=$(TESTS_DPD:%.dpd=%.dot)
TESTS=$(TESTS_DPD) $(TESTS_DOT) $(TESTDIR)/graph.without.dot $(TESTDIR)/search
TESTS_LOG=$(TESTS:%=%.log)
TESTS_ORACLE=$(TESTS:%=%.oracle)
TESTS_OK=$(TESTS:%=%.ok)

DISTRIBUTED+=$(TESTS_SRC) $(TESTS_ORACLE)

.PRECIOUS : $(TESTS) $(TESTS_LOG) $(TESTS_ORACLE)

test : $(TESTS_OK)

%.log : %
	cp $< $@

%.vo : %.v
	coqc $<

%.html : %.v
	coqdoc $<

%.svg : %.dot
	dot -Tsvg -o$@ $<

%.dpd : %.vo %.cmd $(COQEXE)
	# cd to tests to generate .dpd file there.
	cd $(TESTDIR); ../$(COQEXE) < $(*F).cmd > /dev/null  2>&1

Morph%.dpd : $(TESTDIR)/Morph.vo $(TESTDIR)/Morph.cmd $(COQEXE)
	# cd to tests to generate .dpd file there.
	cd $(TESTDIR); ../$(COQEXE) < Morph.cmd > /dev/null  2>&1

graph%.dpd : $(TESTDIR)/Test.vo $(TESTDIR)/Test.cmd $(COQEXE)
	# cd to tests to generate .dpd file there.
	cd $(TESTDIR); ../$(COQEXE) < Test.cmd > /dev/null  2>&1

$(TESTDIR)/search.log : $(TESTDIR)/Test.vo $(TESTDIR)/search.cmd $(COQEXE)
	$(COQEXE) -I $(TESTDIR) <  $(TESTDIR)/search.cmd > $@ 2> /dev/null

%.dot : %.dpd  $(DPD2DOT)
	$(DPD2DOT) $< > /dev/null

%.without.dot : %.dpd  $(DPD2DOT)
	$(DPD2DOT) -without-defs -o $@ $< > /dev/null

%.zgr : %.dot
	zgrviewer $<

%.ok : %.log %.oracle
	$(ECHO_CIBLE)
	@if diff $*.oracle $*.log > /dev/null ; then \
          echo "Bravo... Test [32mOk[0m" ; \
          touch $@ ; \
        else \
          echo "[31mDIFFERENCES[0m : diff $*.oracle $*.log" ; \
          echo "Pour forcer une nouvelle execution du test :" ; \
	  echo "  rm $*.log ; make $*.ok"; \
          echo "[31mPour accepter faire[0m : " ; \
          echo "  cp $*.log $*.oracle" ; \
          rm -f $@ ; \
        fi

# l'oracle est mis � jour par l'utilisateur, mais il faut en avoir 1.
%.oracle :
	$(ECHO_CIBLE) "[ATTENTION : g�n�ration automatique d'oracle]"
	$(MAKE) $*.log
	cp $*.log $*.oracle

#-------------------------------------------------------------------------------
DISTRIBUTED+=Makefile LICENSE README VERSION

distrib : $(NAME)-$(VERSION).tgz

%.tgz : clean
	$(ECHO_CIBLE)
	rm -rf $* $@
	mkdir $*
	cp --parents $(DISTRIBUTED) $*
	tar zcvf $@ $*
	rm -rf $*


#-------------------------------------------------------------------------------
PUB_DIR=/home/anne/public_html/dev/$(NAME)/

PUB_FILES=README \
	   coqdoc.css style.css Test.html \
	   graphTestPerm.svg graphTestReDun.svg

# pub : $(PUB_FILES:%=$(PUB_DIR)/%)
pub :
	# cp *.tgz $(PUB_DIR) do this manually on tom

$(PUB_DIR)/% : %
	cp $< $@

#-------------------------------------------------------------------------------
clean_coq : Make_coq
	$(MAKE) -f $< clean

clean_test :
	rm -f $(TESTS) $(TESTS_LOG) $(TESTS_OK) 
	rm -f $(TESTDIR)/Test.vo  $(TESTDIR)/Test.glob
	rm -f $(TESTDIR)/Morph.vo  $(TESTDIR)/Morph.glob

clean : clean_coq clean_test
	rm -f $(GENERATED) 
	rm -f $(CMOS) $(CMXS) $(ML_ALL:%.ml=%.o) *.cmi
	rm -f $(ML_ALL:%.ml=%.annot)
	rm -f $(DPD2DOT) $(COQEXE)

