{-# OPTIONS --cubical --safe --hidden-argument-pun #-}

module Predicate where

open import Prelude public
open import Relations
open import Cubical.Foundations.HLevels
open import Cubical.HITs.PropositionalTruncation renaming (rec to recTrunc ; map to mapTrunc)
open import Cubical.Foundations.Isomorphism

------------------------------------------------------------------------------
-- This file disguises properties as sets and multisets as dependent types. --
-- In my experience, if a set theory has a universe in context (often used  --
-- for set complements and arbitrary intersections (consider ∅ᶜ and ⋂∅)),   --
-- then the sets can be replaced with properties.                           --
------------------------------------------------------------------------------

_∈_ : A → (A → Type l) → Type l
_∈_ = _|>_
infixr 5 _∈_

_∉_ :  A → (A → Type l) → Type l
_∉_ a X = ¬(a ∈ X)
infixr 5 _∉_

-- We define a property as a function that maps elements to propositions.
record Property {A : Type al} (P : A → Type l) : Type(al ⊔ l) where
 field
  setProp : ∀ x → isProp (x ∈ P)
open Property {{...}} public

record SetFamily {A : Type al} (M : A → Type l) : Type(al ⊔ l) where
 field
  setFamily : ∀ x → isSet (x ∈ M)
open SetFamily {{...}} public

module _{A : Type l}(_∙_ : A → A → A) where

 lCoset : (A → Type l') → A → A → Type (l ⊔ l')
 lCoset H a = λ x → ∃ λ y → (y ∈ H) × (x ≡ a ∙ y)

 rCoset : (A → Type l') → A → A → Type (l ⊔ l')
 rCoset H a = λ x → ∃ λ y → (y ∈ H) × (x ≡ y ∙ a)

-- https://en.wikipedia.org/wiki/Centralizer_and_def1

 centralizer : (A → Type l') → A → Type (l ⊔ l')
 centralizer X a = ∀ x → x ∈ X → a ∙ x ≡ x ∙ a

 normalizer : (A → Type l') → A → Type (lsuc (l ⊔ l'))
 normalizer X a = lCoset X a ≡ rCoset X a

 -- https://en.wikipedia.org/wiki/Center_(group_theory)
 center : A → Type l
 center = centralizer (λ _ → ⊤)

DeMorgan5 : {P : A → Type l} → ¬ Σ P → ∀ x → x ∉ P
DeMorgan5 f x p = f (x , p)

DeMorgan6 : {P : A → Type l} → (∀ a → a ∉ P) → ¬ Σ P
DeMorgan6 f (a , p) = f a p

-- Full predicate
𝓤 : A → Type l
𝓤 = λ _ → Lift ⊤

-- Empty predicate
∅ : A → Type l
∅ = λ _ → Lift ⊥

chain : {A : Type al} {_≤_ : A → A → Type} → {{_ : Poset _≤_}} → (A → Type al) → Type al
chain {_≤_ = _≤_} C = ∀ a b → a ∈ C → b ∈ C → ¬(a ≤ b) → b ≤ a

instance

 ΣSet : {{is-set A}} → {X : A → Type l} → {{SetFamily X}} → is-set (Σ X)
 ΣSet = record { IsSet = isSetΣ IsSet λ x → setFamily x }

 propertyIsMultipredicate : {X : A → Type l} → {{Property X}} → SetFamily X
 propertyIsMultipredicate = record { setFamily = λ x → isProp→isSet (setProp x) }

 fullProp : Property $ 𝓤 {A = A} {l}
 fullProp = record { setProp = λ x tt tt → refl }

 centralizerProperty : {{_ : is-set A}} → {_∙_ : A → A → A}
                     → {H : A → Type l} → Property (centralizer _∙_ H)
 centralizerProperty {_∙_} =
     record { setProp = λ x → isPropΠ λ y → isProp→ (IsSet (x ∙ y) (y ∙ x)) }

 imageProp : {f : A → B} → Property (image f)
 imageProp = record { setProp = λ x → squash₁ }

data Support{A : Type al}(X : A → Type l) : A → Type(al ⊔ l) where
  supportIntro : ∀ x → x ∈ X → x ∈ Support X 
  supportProp : ∀ x → isProp (x ∈ Support X)

supportRec : {X : A → Type al} → isProp B → ∀ x → (x ∈ X → B) → x ∈ Support X → B
supportRec {X} BProp x f (supportIntro .x x∈X) = f x∈X
supportRec {X} BProp x f (supportProp .x z y i) = BProp (supportRec BProp x f z)
                                                        (supportRec BProp x f y) i

instance
 -- The support of a multitype 'X' is an underlying property
 supportProperty : {X : A → Type l} → Property (Support X)
 supportProperty = record { setProp = λ x → supportProp x }

-- Multitype union
_⊎_ : (A → Type l) → (A → Type l') → A → Type (l ⊔ l')
X ⊎ Y = λ x → (x ∈ X) ＋ (x ∈ Y)
infix 6 _⊎_

-- Union
_∪_ : (A → Type l) → (A → Type l') → A → Type (l ⊔ l')
X ∪ Y = λ x → ∥ (x ∈ X) ＋ (x ∈ Y) ∥₁
infix 6 _∪_

-- Intersection
_∩_ : (A → Type l) → (A → Type l') → A → Type (l ⊔ l')
X ∩ Y = λ x → (x ∈ X) × (x ∈ Y)
infix 7 _∩_

-- Complement
_ᶜ : (A → Type l) → A → Type l
X ᶜ = λ x → x ∉ X
infix 20 _ᶜ

record inclusion (A : Type al)(B : Type bl) (l' : Level) : Type(lsuc (al ⊔ bl ⊔ l')) where
 field
   _⊆_ : A → B → Type l'
open inclusion {{...}} public

instance
 sub1 : {A : Type al} → inclusion (A → Type l)(A → Type l') (al ⊔ l ⊔ l')
 sub1 = record { _⊆_ = λ X Y → ∀ x → x ∈ X → ∥ x ∈ Y ∥₁ }

 sub2 : {A : Type al}{_≤_ : A → A → Type l}{{_ : Preorder _≤_}}{P : A → Type bl}
      → inclusion (Σ P) (Σ P) l
 sub2 {_≤_ = _≤_} = record { _⊆_ = λ X Y → fst X ≤ fst Y }

 ∩Prop : {X : A → Type al} → {{_ : Property X}}
       → {Y : A → Type bl} → {{_ : Property Y}}
       → Property (X ∩ Y)
 ∩Prop = record { setProp = λ x → isProp× (setProp x) (setProp x) }

 inclusionPre : {A : Type al} → Preorder (λ(X Y : A → Type l) → X ⊆ Y)
 inclusionPre = record
   { transitive = λ{a b c} f g x z → f x z >>= λ p →
                                     g x p >>= λ q → η q
   ; reflexive = λ _ x z → η z
   ; isRelation = λ a b x y → funExt λ z → funExt λ w → squash₁ (x z w) (y z w)
   }

 inclusionPre2 : {P : A → Type al} → {_≤_ : A → A → Type l} → {{_ : Preorder _≤_}}
               → Preorder (λ(X Y : Σ P) → fst X ≤ fst Y)
 inclusionPre2 {_≤_ = _≤_} = record
   { transitive = λ{a b c} p q → transitive {a = fst a} p q
   ; reflexive = λ a → reflexive (fst a)
   ; isRelation = λ a b → isRelation (fst a) (fst b)
   }

 inclusionPos2 : {P : A → Type al}
               → {_≤_ : A → A → Type l} → {{_ : Poset _≤_}}
               → Poset (λ(X Y : Σ λ x → ¬(¬(P x))) → fst X ≤ fst Y)
 inclusionPos2 {_≤_ = _≤_} = record
   { antiSymmetric = λ {a b} x y → let H = antiSymmetric {a = fst a} {b = fst b} x y
      in ΣPathPProp (λ p q r → funExt (λ s → r s |> UNREACHABLE)) (antiSymmetric {a = fst a} x y)
   }
  where
   open import Cubical.Foundations.HLevels

∩Complement : (X : A → Type l) → X ∩ X ᶜ ≡ ∅
∩Complement X = funExt λ x → isoToPath (iso (λ(a , b) → b a |> UNREACHABLE)
                                            (λ()) (λ()) λ(a , b) → b a |> UNREACHABLE)

-- Union and intersection operations are associative and commutative
instance
 ∪comm : Commutative (_∪_ {A = A} {l})
 ∪comm {A} {l} = record { comm = λ X Y → funExt λ x →
    let H : (X Y : A → Type l) → x ∈ X ∪ Y → x ∈ Y ∪ X
        H X Y = map (λ{ (inl p) → inr p ; (inr p) → inl p}) in
            propExt squash₁ squash₁ (map λ{ (inl x∈X) → inr x∈X ; (inr x∈Y) → inl x∈Y})
                                   $ map λ{ (inl x∈Y) → inr x∈Y ; (inr x∈X) → inl x∈X} }
 ∩comm : Commutative (_∩_ {A = A} {l})
 ∩comm = record { comm = λ X Y → funExt λ x → isoToPath (iso (λ(a , b) → b , a)
                                                             (λ(a , b) → b , a)
                                                             (λ b → refl)
                                                              λ b → refl) }
