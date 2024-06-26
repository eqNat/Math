.PHONY: all
all: Classical/Trigonometry.agdai Classical/Topology.agdai NumberTheory/Finite.agdai Data/Matrix.agdai Algebra/Metric.agdai Classical/SetTheory.agdai

#NumberTheory/Integer.agdai: NumberTheory/Integer.agda NumberTheory/Natural.agdai Data/Integer.agdai
#	agda $<

NumberTheory/Finite.agdai: NumberTheory/Finite.agda NumberTheory/Natural.agdai Data/Bool.agdai Data/Finite.agdai
	agda $<

NumberTheory/Natural.agdai: NumberTheory/Natural.agda NumberTheory/Overloads.agdai
	agda $<

NumberTheory/Overloads.agdai: NumberTheory/Overloads.agda Data/Natural.agdai
	agda $<

Classical/Trigonometry.agdai: Classical/Trigonometry.agda Algebra/Field.agdai
	agda $<

Classical/Topology.agdai: Classical/Topology.agda
	agda $<

Data/Bool.agdai: Data/Bool.agda Algebra/Field.agdai Relations.agdai
	agda $<

Data/Integer.agdai: Data/Integer.agda Data/Natural.agdai Algebra/CRing.agdai
	agda $<

Data/Matrix.agdai: Data/Matrix.agda Algebra/Linear.agdai Data/Finite.agdai
	agda $<

Data/Finite.agdai: Data/Finite.agda Data/Natural.agdai
	agda $<

Data/Natural.agdai: Data/Natural.agda Algebra/Monoid.agdai Algebra/MultAdd.agdai Relations.agdai
	agda $<

Algebra/Linear.agdai: Algebra/Linear.agda Algebra/Field.agdai Algebra/Module.agdai
	agda $<

Algebra/Module.agdai: Algebra/Module.agda Algebra/CRing.agdai Predicate.agdai
	agda $<

Algebra/Metric.agdai: Algebra/Metric.agda Algebra/OrderedRng.agdai
	agda $<

Algebra/OrderedRng.agdai: Algebra/OrderedRng.agda Algebra/Field.agdai Relations.agdai
	agda $<

Algebra/Field.agdai: Algebra/Field.agda Algebra/CRing.agdai
	agda $<

Algebra/CRing.agdai: Algebra/CRing.agda Algebra/Ring.agdai
	agda $<

Algebra/Ring.agdai: Algebra/Ring.agda Algebra/Rng.agdai
	agda $<

Algebra/Rng.agdai: Algebra/Rng.agda Algebra/Group.agdai Algebra/MultAdd.agdai
	agda $<

Algebra/MultAdd.agdai: Algebra/MultAdd.agda Prelude.agdai
	agda $<

Algebra/Group.agdai: Algebra/Group.agda Algebra/Monoid.agdai
	agda $<

Algebra/Monoid.agdai: Algebra/Monoid.agda Prelude.agdai Predicate.agdai
	agda $<

Predicate.agdai: Predicate.agda Relations.agdai
	agda $<

Classical/SetTheory.agdai: Classical/SetTheory.agda Prelude.agdai Relations.agdai
	agda $<

Relations.agdai: Relations.agda Prelude.agdai
	agda $<

Prelude.agdai: Prelude.agda
	agda $<

.PHONY: clean
clean:
	find -type f -name "*\.agdai" -exec rm {} \;
