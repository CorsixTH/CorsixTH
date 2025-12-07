.PHONY: pngs

SOURCES = visit_user.dot global.dot walk.dot reception_visit.dot

pngs:: $(SOURCES:.dot=.png)

%.png : %.dot ; dot -Tpng $< > $@
