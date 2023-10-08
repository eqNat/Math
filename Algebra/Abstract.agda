{-# OPTIONS  --without-K --safe --overlapping-instances #-}

module Algebra.Abstract where

open import Prelude public

record Associative {A : Type l}(f : A → A → A) : Type(lsuc l) where
  field
      associative : (a b c : A) → f a (f b c) ≡ f (f a b) c
open Associative {{...}} public

record Commutative {A : Type l}(_∙_ : A → A → A) : Type(lsuc l) where
  field
    commutative : (a b : A) → _∙_ a b ≡ _∙_ b a
open Commutative {{...}} public

-- https://en.wikipedia.org/wiki/Monoid
record monoid {A : Type l}(_∙_ : A → A → A) : Type(lsuc l) where
  field
      e : A
      IsSet : isSet A
      lIdentity : (a : A) → e ∙ a ≡ a
      rIdentity : (a : A) → a ∙ e ≡ a
      overlap {{mAssoc}} : Associative _∙_

-- https://en.wikipedia.org/wiki/Group_(mathematics)
record group {A : Type l}(_∙_ : A → A → A) : Type(lsuc l) where
  field
      e : A
      IsSet : isSet A
      inverse : (a : A) → Σ λ(b : A) → b ∙ a ≡ e
      lIdentity : (a : A) → e ∙ a ≡ a
      overlap {{gAssoc}} : Associative _∙_

module _{_∙_ : A → A → A} {{G : group _∙_}} where

  open group {{...}}

  -- Extracting an inverse function from 'inverse'
  inv : A → A
  inv a = pr1(inverse a)

  -- Extracting left-inverse property from inverse
  lInverse : (a : A) → (inv a) ∙ a ≡ e
  lInverse a = pr2(inverse a)

  -- Proof that a group has right inverse property
  rInverse : (a : A) → a ∙ (inv a) ≡ e
  rInverse a =
      a ∙ inv a                          ≡⟨ sym (lIdentity (a ∙ inv a))⟩
      e ∙ (a ∙ inv a)                    ≡⟨ left _∙_ (sym (lInverse (inv a)))⟩
      (inv(inv a) ∙ inv a) ∙ (a ∙ inv a) ≡⟨ sym (associative (inv(inv a)) (inv a) (a ∙ inv a))⟩
      inv(inv a) ∙ (inv a ∙ (a ∙ inv a)) ≡⟨ right _∙_ (associative (inv a) a (inv a))⟩
      inv(inv a) ∙ ((inv a ∙ a) ∙ inv a) ≡⟨ right _∙_ (left _∙_ (lInverse a))⟩
      inv(inv a) ∙ (e ∙ (inv a))         ≡⟨ right _∙_ (lIdentity (inv a))⟩
      inv(inv a) ∙ (inv a)               ≡⟨ lInverse (inv a)⟩
      e ∎

instance
  -- Proof that all groups are monoids
  grpIsMonoid : {_∙_ : A → A → A}{{_ : group _∙_}} → monoid _∙_
  grpIsMonoid {_∙_ = _∙_} =
   record {
          e = e
        ; lIdentity = lIdentity
        ; IsSet = IsSet
        -- Proof that a group has right identity property
        ; rIdentity =
           λ a →
           a ∙ e           ≡⟨ right _∙_ (sym (lInverse a))⟩
           a ∙ (inv a ∙ a) ≡⟨ associative a (inv a) a ⟩
           (a ∙ inv a) ∙ a ≡⟨ left _∙_ (rInverse a)⟩
           e ∙ a           ≡⟨ lIdentity a ⟩
           a ∎
   }
   where
     open group {{...}}

open monoid {{...}} public

-- Identity element of a monoid is unique
idUnique : {_∙_ : A → A → A} {{_ : monoid _∙_}} → (a : A) → ((x : A) → a ∙ x ≡ x) → a ≡ e
idUnique {A = A} {_∙_ = _∙_} a =
  λ(p : (x : A) → a ∙ x ≡ x) →
    a     ≡⟨ sym (rIdentity a) ⟩
    a ∙ e ≡⟨ p e ⟩
    e ∎

module grp {_∙_ : A → A → A} {{G : group _∙_}} where

  cancel : (a : A) → {x y : A} → a ∙ x ≡ a ∙ y → x ≡ y
  cancel a {x}{y} =
    λ(p : a ∙ x ≡ a ∙ y) →
      x               ≡⟨ sym (lIdentity x)⟩
      e ∙ x           ≡⟨ left _∙_ (sym (lInverse a))⟩
      (inv a ∙ a) ∙ x ≡⟨ sym (associative (inv a) a x)⟩
      inv a ∙ (a ∙ x) ≡⟨ right _∙_ p ⟩
      inv a ∙ (a ∙ y) ≡⟨ associative (inv a) a y ⟩
      (inv a ∙ a) ∙ y ≡⟨ left _∙_ (lInverse a)⟩
      e ∙ y           ≡⟨ lIdentity y ⟩
      y ∎

  invInjective : {x y : A} → inv x ≡ inv y → x ≡ y
  invInjective {x}{y} =
    λ(p : inv x ≡ inv y) →
      x               ≡⟨ sym (rIdentity x)⟩
      x ∙ e           ≡⟨ right _∙_ (sym (lInverse y))⟩
      x ∙ (inv y ∙ y) ≡⟨ right _∙_ (left _∙_ (sym p))⟩
      x ∙ (inv x ∙ y) ≡⟨ associative x (inv x) y ⟩
      (x ∙ inv x) ∙ y ≡⟨ left _∙_ (rInverse x)⟩
      e ∙ y           ≡⟨ lIdentity y ⟩
      y ∎

  doubleInv : (x : A) → inv (inv x) ≡ x
  doubleInv x = 
    inv(inv x)               ≡⟨ sym (rIdentity (inv (inv x)))⟩
    inv(inv x) ∙ e           ≡⟨ right _∙_ (sym (lInverse x))⟩
    inv(inv x) ∙ (inv x ∙ x) ≡⟨ associative (inv(inv x)) (inv x) x ⟩
    (inv(inv x) ∙ inv x) ∙ x ≡⟨ left _∙_ (lInverse (inv x))⟩
    e ∙ x                    ≡⟨ lIdentity x ⟩
    x ∎

  uniqueInv : {x y : A} → x ∙ (inv y) ≡ e → x ≡ y
  uniqueInv {x}{y} =
    λ(p : x ∙ inv y ≡ e) →
      x               ≡⟨ sym (rIdentity x)⟩
      x ∙ e           ≡⟨ right _∙_ (sym (lInverse y))⟩
      x ∙ (inv y ∙ y) ≡⟨ associative x (inv y) y ⟩
      (x ∙ inv y) ∙ y ≡⟨ left _∙_ p ⟩
      e ∙ y           ≡⟨ lIdentity y ⟩
      y ∎

  lemma1 : (a b : A) → inv b ∙ inv a ≡ inv (a ∙ b)
  lemma1 a b =
    let H : (inv b ∙ inv a) ∙ inv(inv(a ∙ b)) ≡ e
                              → inv b ∙ inv a ≡ inv (a ∙ b)
        H = uniqueInv in H $
    (inv b ∙ inv a) ∙ inv(inv(a ∙ b)) ≡⟨ right _∙_ (doubleInv (a ∙ b))⟩
    (inv b ∙ inv a) ∙ (a ∙ b)         ≡⟨ sym (associative (inv b) (inv a) (a ∙ b))⟩
    inv b ∙ (inv a ∙ (a ∙ b))         ≡⟨ right _∙_ (associative (inv a) a b)⟩
    inv b ∙ ((inv a ∙ a) ∙ b)         ≡⟨ right _∙_ (left _∙_ (lInverse a))⟩
    inv b ∙ (e ∙ b)                   ≡⟨ right _∙_ (lIdentity b)⟩
    inv b ∙ b                         ≡⟨ lInverse b ⟩
    e ∎
  
  lemma2 : {a b c : A} → c ≡ a ∙ b → inv a ∙ c ≡ b
  lemma2 {a}{b}{c} =
    λ(p : c ≡ a ∙ b) →
      inv a ∙ c       ≡⟨ right _∙_ p ⟩
      inv a ∙ (a ∙ b) ≡⟨ associative (inv a) a b ⟩
      (inv a ∙ a) ∙ b ≡⟨ left _∙_ (lInverse a)⟩
      e ∙ b           ≡⟨ lIdentity b ⟩
      b ∎

  lemma3 : {a : A} → a ≡ a ∙ a → a ≡ e
  lemma3 {a = a} =
    λ(p : a ≡ a ∙ a) →
      a         ≡⟨ sym (lemma2 p)⟩
      inv a ∙ a ≡⟨ lInverse a ⟩
      e ∎

  lemma4 : inv e ≡ e
  lemma4 =
    inv e     ≡⟨ sym (lIdentity (inv e))⟩
    e ∙ inv e ≡⟨ rInverse e ⟩
    e ∎

record grpHomomorphism {A : Type l}
                       {B : Type l'} 
                       (_∙_ : A → A → A) {{G : group _∙_}}
                       (_*_ : B → B → B) {{H : group _*_}} : Type(l ⊔ l') 
  where field
    h : A → B
    homomophism : (u v : A) → h (u ∙ v) ≡ h u * h v

assocCom4 : {_∙_ : A → A → A}{{_ : Commutative _∙_}}{{_ : monoid _∙_}}
          → (a b c d : A) → (a ∙ b) ∙ (c ∙ d) ≡ (a ∙ c) ∙ (b ∙ d)
assocCom4 {_∙_ = _∙_} a b c d =
  (a ∙ b) ∙ (c ∙ d) ≡⟨ associative (_∙_ a b) c d ⟩
  ((a ∙ b) ∙ c) ∙ d ≡⟨ left _∙_ (sym(associative a b c))⟩
  (a ∙ (b ∙ c)) ∙ d ≡⟨ left _∙_ (right _∙_ (commutative b c))⟩
  (a ∙ (c ∙ b)) ∙ d ≡⟨ left _∙_ (associative a c b)⟩
  ((a ∙ c) ∙ b) ∙ d ≡⟨ sym (associative (_∙_ a c) b d)⟩
  (a ∙ c) ∙ (b ∙ d) ∎

-- https://en.wikipedia.org/wiki/Abelian_group
record abelianGroup {A : Type l}(_∙_ : A → A → A) : Type (lsuc l) where
  field
      {{grp}} : group _∙_
      {{comgroup}} : Commutative _∙_
open abelianGroup {{...}} public

-- https://en.wikipedia.org/wiki/Rng_(algebra)
record Rng (A : Type l) : Type (lsuc l) where
  field
    _+_ : A → A → A
    _*_ : A → A → A
    lDistribute : (a b c : A) → a * (b + c) ≡ (a * b) + (a * c)
    rDistribute : (a b c : A) → (b + c) * a ≡ (b * a) + (c * a)
    {{raddStr}} : abelianGroup _+_
open Rng {{...}} public

zero : {{SR : Rng A}} → A
zero = e

nonZero : {A : Type l} {{R : Rng A}} → Type l
nonZero {A = A} = Σ λ (a : A) → a ≠ zero

neg : {{R : Rng A}} → A → A
neg = inv

rMultZ : {{R : Rng A}} → (x : A) → x * zero ≡ zero
rMultZ x =
  x * zero                                ≡⟨ sym (rIdentity (x * zero))⟩
  (x * zero) + zero                       ≡⟨ right _+_ (sym (rInverse (x * zero)))⟩
  (x * zero)+((x * zero) + neg(x * zero)) ≡⟨ associative (x * zero) (x * zero) (neg(x * zero))⟩
  ((x * zero)+(x * zero)) + neg(x * zero) ≡⟨ left _+_ (sym (lDistribute x zero zero))⟩
  (x * (zero + zero)) + neg(x * zero)     ≡⟨ left _+_ (right _*_ (lIdentity zero))⟩
  (x * zero) + neg(x * zero)              ≡⟨ rInverse (x * zero)⟩
  zero ∎

lMultZ : {{R : Rng A}} → (x : A) → zero * x ≡ zero
lMultZ x =
  zero * x                                ≡⟨ sym (rIdentity (zero * x))⟩
  (zero * x) + zero                       ≡⟨ right _+_ (sym (rInverse (zero * x)))⟩
  (zero * x)+((zero * x) + neg(zero * x)) ≡⟨ associative (zero * x) (zero * x) (neg(zero * x))⟩
  ((zero * x)+(zero * x)) + neg(zero * x) ≡⟨ left _+_ (sym (rDistribute x zero zero))⟩
  ((zero + zero) * x) + neg(zero * x)     ≡⟨ left _+_ (left _*_ (lIdentity zero))⟩
  (zero * x) + neg(zero * x)              ≡⟨ rInverse (zero * x)⟩
  zero ∎

negSwap : {{R : Rng A}} → (x y : A) → neg x * y ≡ x * neg y
negSwap x y =
  let H : (x * y)+(neg x * y) ≡ (x * y)+(x * neg y)
                  → neg x * y ≡ x * neg y
      H = grp.cancel (x * y) in H $
  (x * y)+(neg x * y)   ≡⟨ sym(rDistribute y x (neg x))⟩
  (x + neg x) * y       ≡⟨ left _*_ (rInverse x)⟩
  zero * y              ≡⟨ lMultZ y ⟩
  zero                  ≡⟨ sym (rMultZ x)⟩
  x * zero              ≡⟨ right _*_ (sym (rInverse y))⟩
  x * (y + neg y)       ≡⟨ lDistribute x y (neg y)⟩
  (x * y)+(x * neg y) ∎

multNeg : {{R : Rng A}} → (x y : A) → (neg x) * y ≡ neg(x * y)
multNeg x y =
  let H : (x * y)+(neg x * y) ≡ (x * y) + neg(x * y)
                  → neg x * y ≡ neg(x * y)
      H = grp.cancel (x * y) in H $
  (x * y)+(neg x * y) ≡⟨ sym(rDistribute y x (neg x))⟩
  (x + neg x) * y     ≡⟨ left _*_ (rInverse x)⟩
  zero * y            ≡⟨ lMultZ y ⟩
  zero                ≡⟨ sym (rInverse (x * y))⟩
  (x * y) + neg(x * y) ∎

-- https://en.wikipedia.org/wiki/Ring_(mathematics)
record Ring (A : Type l) : Type (lsuc l) where
  field
    {{rngring}} : Rng A
    {{multStr}} : monoid _*_
open Ring {{...}} public

one : {{SR : Ring A}} → A
one = multStr .e

_-_ : {{R : Rng A}} → A → A → A
a - b = a + (neg b)

lMultNegOne : {{R : Ring A}} → (x : A) → neg one * x ≡ neg x
lMultNegOne x =
  let H : (neg one * x)+(neg(neg x)) ≡ zero
                       → neg one * x ≡ neg x
      H = grp.uniqueInv in H $
  (neg one * x)+(neg(neg x)) ≡⟨ right _+_ (grp.doubleInv x)⟩
  (neg one * x) + x          ≡⟨ right _+_ (sym (lIdentity x))⟩
  (neg one * x)+(one * x)    ≡⟨ sym (rDistribute x (neg one) one)⟩
  (neg one + one) * x        ≡⟨ left _*_ (lInverse one)⟩
  zero * x                   ≡⟨ lMultZ x ⟩
  zero ∎

rMultNegOne : {{R : Ring A}} → (x : A) → x * neg one ≡ neg x
rMultNegOne x =
  let H : (x * neg one)+(neg(neg x)) ≡ zero
                       → x * neg one ≡ neg x
      H = grp.uniqueInv in H $
  (x * neg one)+(neg(neg x)) ≡⟨ right _+_ (grp.doubleInv x)⟩
  (x * neg one) + x          ≡⟨ right _+_ (sym (rIdentity x))⟩
  (x * neg one)+(x * one)    ≡⟨ sym (lDistribute x (neg one) one)⟩
  x * (neg one + one)        ≡⟨ right _*_ (lInverse one)⟩
  x * zero                   ≡⟨ rMultZ x ⟩
  zero ∎

-- https://en.wikipedia.org/wiki/Commutative_ring
record CRing (A : Type l) : Type (lsuc l) where
  field
    {{crring}} : Ring A
    {{ringCom}} : Commutative _*_
open CRing {{...}} public

-- https://en.wikipedia.org/wiki/Field_(mathematics)
record Field (A : Type l) : Type (lsuc l) where
  field
    {{fring}} : CRing A
    oneNotZero : one ≠ zero
    reciprocal : nonZero → nonZero
    recInv : (a : nonZero) → pr1(reciprocal a) * pr1 a ≡ one
open Field {{...}} public

-- Multiplying two nonzero values gives a nonzero value
nonZeroMult : {{F : Field A}} (a b : nonZero) → (pr1 a * pr1 b) ≠ zero
nonZeroMult (a , a') (b , b') = λ(f : (a * b) ≡ zero) →
  let H : (pr1 (reciprocal (a , a'))) * (a * b) ≡ (pr1 (reciprocal (a , a'))) * zero
      H = right _*_ f in
  let G : (pr1 (reciprocal (a , a'))) * zero ≡ zero
      G = rMultZ (pr1 (reciprocal (a , a'))) in
  let F = b       ≡⟨ sym(lIdentity b)⟩
          one * b ≡⟨ left _*_ (sym (recInv ((a , a'))))⟩
          ((pr1 (reciprocal (a , a'))) * a) * b ≡⟨ sym (associative (pr1 (reciprocal (a , a'))) a b)⟩
          (pr1 (reciprocal (a , a'))) * (a * b) ∎ in
  let contradiction : b ≡ zero
      contradiction = eqTrans F (eqTrans H G)
      in b' contradiction

nonZMult : {{F : Field A}} → nonZero → nonZero → nonZero
nonZMult (a , a') (b , b') = (a * b) , nonZeroMult (a , a') ((b , b'))

-- https://en.wikipedia.org/wiki/Module_(mathematics)
-- Try not to confuse 'Module' with Agda's built-in 'module' keyword.
record Module {scalar : Type l} {{R : Ring scalar}} : Type (lsuc l) where
  field
    vector : Type l
    _[+]_ : vector → vector → vector
    addvStr : abelianGroup _[+]_
    scale : scalar → vector → vector
    scalarDistribution : (a : scalar) → (u v : vector) → scale a (u [+] v) ≡ (scale a u) [+] (scale a v)
    vectorDistribution : (v : vector) → (a b : scalar) → scale (a + b) v ≡ (scale a v) [+] (scale b v)
    scalarAssoc : (v : vector) → (a b : scalar) → scale a (scale b v) ≡ scale (b * a) v
    scaleId : (v : vector) → scale one v ≡ v
open Module {{...}} public

module _{scalar : Type l}{{R : Ring scalar}}{{V : Module}} where

  vZero : vector
  vZero = e

  negV : vector → vector
  negV = inv

  _[-]_ : vector → vector → vector
  a [-] b = a [+] (negV b)

  vGrp : group _[+]_
  vGrp = abelianGroup.grp addvStr

  -- Vector scaled by zero is zero vector
  scaleZ : (v : vector) → scale zero v ≡ vZero
  scaleZ v =
    let H : scale zero v [+] scale zero v ≡ (scale zero v [+] vZero)
                           → scale zero v ≡ vZero
        H = grp.cancel (scale zero v) in H $
    scale zero v [+] scale zero v ≡⟨ sym (vectorDistribution v zero zero)⟩
    scale (zero + zero) v         ≡⟨ left scale (lIdentity zero)⟩
    scale zero v                  ≡⟨ sym (rIdentity (scale zero v))⟩
    scale zero v [+] vZero ∎

  -- Zero vector scaled is zero vector
  scaleVZ : (c : scalar) → scale c vZero ≡ vZero
  scaleVZ c =
    let H : scale c vZero [+] scale c vZero ≡ scale c vZero [+] vZero
                            → scale c vZero ≡ vZero
        H = grp.cancel (scale c vZero) in H $
    scale c vZero [+] scale c vZero ≡⟨ sym (scalarDistribution c vZero vZero)⟩
    scale c (vZero [+] vZero)       ≡⟨ right scale (lIdentity vZero)⟩
    scale c vZero                   ≡⟨ sym (rIdentity (scale c vZero))⟩
    scale c vZero [+] vZero ∎

  scaleNegOneInv : (v : vector) → scale (neg one) v ≡ negV v
  scaleNegOneInv v =
    let H : scale one v [+] scale (neg one) v ≡ scale one v [+] negV v
                         →  scale (neg one) v ≡ negV v     
        H = grp.cancel (scale one v) in H $
    scale one v [+] scale (neg one) v ≡⟨ sym (vectorDistribution v one (neg one))⟩
    scale (one + neg one) v           ≡⟨ left scale (rInverse one)⟩
    scale zero v                      ≡⟨ scaleZ v ⟩
    vZero                             ≡⟨ sym (rInverse v)⟩
    v [+] negV v                      ≡⟨ left _[+]_ (sym (scaleId v))⟩
    scale one v [+] negV v ∎

  scaleInv : (v : vector) → (c : scalar) → scale (neg c) v ≡ (negV (scale c v))
  scaleInv v c =
    let H : scale (neg c) v [+] negV(negV(scale c v)) ≡ vZero
                                    → scale (neg c) v ≡ negV (scale c v)
        H = grp.uniqueInv in H $
    scale (neg c) v [+] negV(negV(scale c v)) ≡⟨ right _[+]_ (grp.doubleInv (scale c v))⟩
    scale (neg c) v [+] (scale c v)           ≡⟨ sym (vectorDistribution v (neg c) c)⟩
    scale ((neg c) + c) v                     ≡⟨ left scale (lInverse c)⟩
    scale zero v                              ≡⟨ scaleZ v ⟩
    vZero ∎

-- Not necessarily a linear span since we're using a module instead of a vector space
  data Span (X : vector → Type l) : vector → Type l where
    intro : {v : vector} → X v → Span X v
    spanAdd : {v : vector} → Span X v → {u : vector} → Span X u → Span X (v [+] u)
    spanScale : {v : vector} → Span X v → (c : scalar) → Span X (scale c v)

  spanJoin : (X : vector → Type l) → (x : vector) → (Span ∘ Span) X x → Span X x
  spanJoin X x (intro p) = p
  spanJoin X x (spanAdd {v} p {u} q) =
      let H = spanJoin X v p in
      let G = spanJoin X u q in spanAdd H G
  spanJoin X x (spanScale {v} p c) = spanScale (spanJoin X v p) c

  -- Not necessarily a linear subspace.
  record Subspace (X : vector → Type l) : Type (lsuc l)
    where field
        ssZero : X vZero 
        ssAdd : {v u : vector} → X v → X u → X (v [+] u)
        ssScale : {v : vector} → X v → (c : scalar) → X (scale c v)

<_> : {A : Type l}{{F : Ring A}}(V : Module) → Type l
< V > = Module.vector V

-- https://en.wikipedia.org/wiki/Module_homomorphism
record moduleHomomorphism  {A : Type l}
                          {{R : Ring A}}
                          {{V U : Module}}
                           (T : < U > → < V >) : Type l
  where field
  addT : (u v : vector) →  T (u [+] v) ≡ T u [+] T v
  multT : (u : vector) → (c : A) → T (scale c u) ≡ scale c (T u)
open moduleHomomorphism {{...}} public 

module _ {scalar : Type l}{{R : Ring scalar}}{{V U : Module}}
         (T : < U > → < V >){{TLT : moduleHomomorphism T}} where

  modHomomorphismZ : T vZero ≡ vZero
  modHomomorphismZ =
          T vZero  ≡⟨ sym (cong T (scaleZ vZero))⟩
          T (scale zero vZero)  ≡⟨ moduleHomomorphism.multT TLT vZero zero ⟩
          scale zero (T vZero)  ≡⟨ scaleZ (T vZero)⟩
          vZero ∎

  -- If 'T' and 'R' are module homomorphisms and are composable, then 'R ∘ T' is a module homomorphism.
  modHomomorphismComp : {{W : Module}}
               →  (R : < V > → < W >)
               → {{SLT : moduleHomomorphism R}}
               → moduleHomomorphism (R ∘ T)
  modHomomorphismComp R = record { addT = λ u v → eqTrans (cong R (addT u v)) (addT (T u) (T v))
                         ; multT = λ u c → eqTrans (cong R (multT u c)) (multT (T u) c) }

week7 : {{CR : CRing A}} → {{V : Module}}
      → (T : < V > → < V >) → {{TLT : moduleHomomorphism T}}
      → (c : A) → Subspace (λ x → T x ≡ scale c x)
week7 T c = record
    { ssZero = T vZero ≡⟨ modHomomorphismZ T ⟩
               vZero   ≡⟨ sym (scaleVZ c)⟩
               scale c vZero ∎
    ; ssAdd = λ {v} {u} (p : T v ≡ scale c v) (q : T u ≡ scale c u) →
                   T (v [+] u)             ≡⟨ addT v u ⟩
                   T v [+] T u             ≡⟨ cong2 _[+]_ p q ⟩
                   scale c v [+] scale c u ≡⟨ sym (scalarDistribution c v u)⟩
                   scale c (v [+] u) ∎
    ; ssScale = λ {v} (p : T v ≡ scale c v) d →
                   T (scale d v)       ≡⟨ multT v d ⟩
                   scale d (T v)       ≡⟨ right scale p ⟩
                   scale d (scale c v) ≡⟨ scalarAssoc v d c ⟩
                   scale (c * d) v     ≡⟨ left scale (commutative c d)⟩
                   scale (d * c) v     ≡⟨ sym (scalarAssoc v c d)⟩
                   scale c (scale d v) ∎
    }