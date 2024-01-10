{-# OPTIONS --cubical --safe --overlapping-instances #-}

module Algebra.Module where

open import Prelude
open import Relations
open import Set
open import Algebra.CRing public
open import Cubical.HITs.PropositionalTruncation renaming (rec to truncRec)

-- https://en.wikipedia.org/wiki/Module_(mathematics)
-- Try not to confuse 'Module' with Agda's built-in 'module' keyword.
record Module {scalar : Type l} {{R : Ring scalar}} (vector : Type l') : Type (lsuc (l ⊔ l')) where
  field
    _[+]_ : vector → vector → vector
    {{addvStr}} : group _[+]_
    {{comMod}} : Commutative _[+]_
    scale : scalar → vector → vector
    scalarDistribute : (a : scalar) → (u v : vector)
                     → scale a (u [+] v) ≡ (scale a u) [+] (scale a v)
    vectorDistribute : (v : vector) → (a b : scalar)
                     → scale (a + b) v ≡ (scale a v) [+] (scale b v)
    scalarAssoc : (v : vector) → (a b : scalar) → scale a (scale b v) ≡ scale (a * b) v
    scaleId : (v : vector) → scale 1r v ≡ v
open Module {{...}} public

module _{scalar : Type l}{vector : Type l'}{{R : Ring scalar}}{{V : Module vector}} where

  Ô : vector
  Ô = e

  negV : vector → vector
  negV = inv

  _[-]_ : vector → vector → vector
  a [-] b = a [+] (negV b)

  -- Vector scaled by 0r is zero vector
  scaleZ : (v : vector) → scale 0r v ≡ Ô
  scaleZ v =
    let H : scale 0r v [+] scale 0r v ≡ (scale 0r v [+] Ô)
                         → scale 0r v ≡ Ô
        H = grp.cancel (scale 0r v) in H $
    scale 0r v [+] scale 0r v ≡⟨ sym (vectorDistribute v 0r 0r)⟩
    scale (0r + 0r) v         ≡⟨ left scale (lIdentity 0r)⟩
    scale 0r v                ≡⟨ sym (rIdentity (scale 0r v))⟩
    scale 0r v [+] Ô ∎

  -- zero vector scaled is 0r vector
  scaleVZ : (c : scalar) → scale c Ô ≡ Ô
  scaleVZ c =
    let H : scale c Ô [+] scale c Ô ≡ scale c Ô [+] Ô
                        → scale c Ô ≡ Ô
        H = grp.cancel (scale c Ô) in H $
    scale c Ô [+] scale c Ô ≡⟨ sym (scalarDistribute c Ô Ô)⟩
    scale c (Ô [+] Ô)       ≡⟨ right scale (lIdentity Ô)⟩
    scale c Ô               ≡⟨ sym (rIdentity (scale c Ô))⟩
    scale c Ô [+] Ô ∎

  scaleInv : (v : vector) → (c : scalar) → scale (neg c) v ≡ negV (scale c v)
  scaleInv v c =
    let H : scale (neg c) v [+] negV(negV(scale c v)) ≡ Ô
                                    → scale (neg c) v ≡ negV (scale c v)
        H = grp.uniqueInv in H $
    scale (neg c) v [+] negV(negV(scale c v)) ≡⟨ right _[+]_ (grp.doubleInv (scale c v))⟩
    scale (neg c) v [+] (scale c v)           ≡⟨ sym (vectorDistribute v (neg c) c)⟩
    scale ((neg c) + c) v                     ≡⟨ left scale (lInverse c)⟩
    scale 0r v                                ≡⟨ scaleZ v ⟩
    Ô ∎

  scaleNegOneInv : (v : vector) → scale (neg 1r) v ≡ negV v
  scaleNegOneInv v =
    scale (neg 1r) v  ≡⟨ scaleInv v 1r ⟩
    negV (scale 1r v) ≡⟨ cong negV (scaleId v)⟩
    negV v ∎

  scaleNeg : (v : vector) → (c : scalar) → scale (neg c) v ≡ scale c (negV v)
  scaleNeg v c = scale (neg c) v             ≡⟨ left scale (sym(rIdentity (neg c)))⟩
                 scale (neg c * 1r) v        ≡⟨ left scale (-x*y≡x*-y c 1r)⟩
                 scale (c * neg 1r) v        ≡⟨ sym (scalarAssoc v c (neg 1r))⟩
                 scale c  (scale (neg 1r) v) ≡⟨ right scale (scaleNegOneInv v)⟩
                 scale c (negV v) ∎

  -- This is a more general definition that uses a module instead of a vector space
  data Span (X : vector → Type al) : vector → Type (l ⊔ l' ⊔ al) where
    intro : {v : vector} → v ∈ X → v ∈ Span X
    spanAdd : {v : vector} → v ∈ Span X → {u : vector} → u ∈ Span X → v [+] u ∈ Span X
    spanScale : {v : vector} → v ∈ Span X → (c : scalar) → scale c v ∈ Span X
    spanSet : {v : vector} → isProp (v ∈ Span X)

  instance
    spanIsSet : {X : vector → Type al} → Property (Span X)
    spanIsSet = record { setProp = λ x y z → spanSet y z }

  spanIdempotent : (Span ∘ Span) ≡ Span {al}
  spanIdempotent = funExt λ X → funExt λ x → propExt spanSet spanSet (aux X x) intro
   where
    aux : (X : vector → Type al) → (x : vector) → x ∈ (Span ∘ Span) X → x ∈ Span X
    aux X x (intro p) = p
    aux X x (spanAdd {v} p {u} q) = spanAdd (aux X v p) (aux X u q)
    aux X x (spanScale {v} p c) = spanScale (aux X v p) c
    aux X x (spanSet {v} p q H) = spanSet (aux X v p) (aux X v q) H

  support→span : (X : vector → Type al) → ∀ v → v ∈ Support X → v ∈ Span X
  support→span X v (supportIntro .v x) = intro x
  support→span X v (supportProp .v x y i) = spanSet (support→span X v x) (support→span X v y) i

  spanSupport : (X : vector → Type al) → Span (Support X) ≡ Span X
  spanSupport X = funExt λ v → propExt spanSet spanSet (aux1 v) (aux2 v)
    where
     aux1 : ∀ v → v ∈ Span (Support X) → v ∈ Span X
     aux1 v (intro x) = support→span X v x
     aux1 v (spanAdd {u} x {w} y) = spanAdd (aux1 u x) (aux1 w y)
     aux1 v (spanScale {u} x c) = spanScale (aux1 u x) c
     aux1 v (spanSet {u} x y i) = spanSet (aux1 v x) (aux1 v y) i
     aux2 : ∀ v → v ∈ Span X → v ∈ Span (Support X)
     aux2 v (intro x) = intro (supportIntro v x)
     aux2 v (spanAdd {u} x {w} y) = spanAdd (aux2 u x) (aux2 w y)
     aux2 v (spanScale {u} x c) = spanScale (aux2 u x) c
     aux2 v (spanSet x y i) = spanSet (aux2 v x) (aux2 v y) i

  span⊆preserve : ∀ {X Y : vector → Type al} → X ⊆ Y → Span X ⊆ Span Y
  span⊆preserve {X = X} {Y} p v (intro x) = truncRec squash₁ (λ z → η (intro z)) (p v x)
  span⊆preserve {X = X} {Y} p v (spanAdd {u} x {w} y) =
     span⊆preserve p u x >>= λ H →
     span⊆preserve p w y >>= λ G → η $ spanAdd H G
  span⊆preserve {X = X} {Y} p v (spanScale {u} x c) = span⊆preserve p u x >>= λ z → η (spanScale z c)
  span⊆preserve {X = X} {Y} p v (spanSet x y i) = squash₁ (span⊆preserve p v x)
                                                          (span⊆preserve p v y) i

  -- This is a more general definition that uses a module instead of a vector space
  record Subspace (X : vector → Type al) : Type (lsuc (al ⊔ l ⊔ l'))
    where field
        ssZero : Ô ∈ X 
        ssAdd : {v u : vector} → v ∈ X → u ∈ X → v [+] u ∈ X
        ssScale : {v : vector} → v ∈ X → (c : scalar) → scale c v ∈ X
        ssSet : {v : vector} → isProp (v ∈ X)
  open Subspace {{...}} public

  -- The span of a non-empty set of vectors is a subspace
  NonEmptySpanIsSubspace :{X : vector → Type al}
                        → Σ X
                        → Subspace (Span X)
  NonEmptySpanIsSubspace {X = X} (v , v') =
      record { ssZero = scaleZ v ~> λ p → subst (Span X) p (spanScale (intro v') 0r)
             ; ssAdd = λ x y → spanAdd x y
             ; ssScale = λ x c → spanScale x c
             ; ssSet = λ {v} → spanSet
             }

  {- This is almost the definition of linear independence except that the set which contains
     only the zero vector is a member. -}
  record Independent (X : vector → Type al) : Type (lsuc (l ⊔ l' ⊔ al))
    where field
        Ind : ∀ Y → Span Y ≡ Span X → Y ⊆ X → Y ≡ X
  open Independent {{...}} public

  instance
   IndSet : {X : vector → Type l'} → {{_ : Independent X}} → Property X
   IndSet {X = X} =
      let H : Support X ≡ X
          H = Ind (Support X) (spanSupport X)
                  λ x → supportRec squash₁ x λ y → η y
       in record { setProp = λ v → transport (λ i → isProp (v ∈ H i)) (supportProp v) }

  record  MaxInd (X : vector → Type al) : Type (lsuc (l ⊔ l' ⊔ al))  where
   field
    {{independent}} : Independent X
    maxInd : ∀ Y → {{Independent Y}} → X ⊆ Y → X ≡ Y
  open MaxInd {{...}} public

  completeSpan : (X : vector → Type l') → {{I : Independent X}} → (∀ v → v ∈ Span X) → MaxInd X
  completeSpan X f = record { maxInd = λ Y (y : X ⊆ Y) →
       let H = span⊆preserve y in
       Ind X (funExt λ z → propExt spanSet spanSet (λ x → truncRec spanSet (λ w → w) (H z x)) λ _ → f z) y
       }

-- https://en.wikipedia.org/wiki/Module_homomorphism
record moduleHomomorphism {A : Type l}
                         {{R : Ring A}}
                          {<V> : Type l'}
                          {<U> : Type al}
                         {{V : Module <V>}}
                         {{U : Module <U>}}
                          (T : <U> → <V>) : Type (l ⊔ l' ⊔ al)
  where field
  addT : ∀ u v →  T (u [+] v) ≡ T u [+] T v
  multT : ∀ u → (c : A) → T (scale c u) ≡ scale c (T u)
open moduleHomomorphism {{...}} public 

modHomomorphismIsProp : {{F : Ring A}}
                      → {{VS : Module B}}
                      → {{VS' : Module C}}
                      → (LT : B → C)
                      → isProp (moduleHomomorphism LT)
modHomomorphismIsProp {{VS' = VS'}} LT x y i = let set = λ{a b p q} → IsSet a b p q in
 record {
    addT = λ u v →
     let H : moduleHomomorphism.addT x u v ≡ moduleHomomorphism.addT y u v
         H = set in H i
  ; multT = λ u c →
     let H : moduleHomomorphism.multT x u c ≡ moduleHomomorphism.multT y u c
         H = set in H i
 }

module _ {scalar : Type l}{{R : Ring scalar}}
         {{V : Module A}}{{U : Module B}}
         (T : A → B){{TLT : moduleHomomorphism T}} where

  modHomomorphismZ : T Ô ≡ Ô
  modHomomorphismZ =
          T Ô             ≡⟨ sym (cong T (scaleZ Ô))⟩
          T (scale 0r Ô)  ≡⟨ moduleHomomorphism.multT TLT Ô 0r ⟩
          scale 0r (T Ô)  ≡⟨ scaleZ (T Ô)⟩
          Ô ∎

  -- If 'T' and 'R' are module homomorphisms and are composable, then 'R ∘ T' is
  -- a module homomorphism.
  modHomomorphismComp : {{W : Module C}}
               →  (R : B → C)
               → {{SLT : moduleHomomorphism R}}
               → moduleHomomorphism (R ∘ T)
  modHomomorphismComp R =
     record { addT = λ u v → cong R (addT u v) ⋆ addT (T u) (T v)
            ; multT = λ u c → cong R (multT u c) ⋆ multT (T u) c }

-- Bad name. I don't know what else to call this theorem.
week7 : {{CR : CRing A}} → {{V : Module B}}
      → (T : B → B) → {{TLT : moduleHomomorphism T}}
      → (c : A) → Subspace (λ x → T x ≡ scale c x)
week7 T c = record
    { ssZero = T Ô ≡⟨ modHomomorphismZ T ⟩
               Ô   ≡⟨ sym (scaleVZ c)⟩
               scale c Ô ∎
    ; ssAdd = λ {v} {u} (p : T v ≡ scale c v) (q : T u ≡ scale c u) →
                   T (v [+] u)             ≡⟨ addT v u ⟩
                   T v [+] T u             ≡⟨ cong₂ _[+]_ p q ⟩
                   scale c v [+] scale c u ≡⟨ sym (scalarDistribute c v u)⟩
                   scale c (v [+] u) ∎
    ; ssScale = λ {v} (p : T v ≡ scale c v) d →
                   T (scale d v)       ≡⟨ multT v d ⟩
                   scale d (T v)       ≡⟨ right scale p ⟩
                   scale d (scale c v) ≡⟨ scalarAssoc v d c ⟩
                   scale (d * c) v     ≡⟨ left scale (comm d c)⟩
                   scale (c * d) v     ≡⟨ sym (scalarAssoc v c d)⟩
                   scale c (scale d v) ∎
    ; ssSet = λ {v} → IsSet (T v) (scale c v)
    }

module _ {A : Type l}  {{CR : CRing A}}
         {V : Type al} {{V' : Module V}}
         {W : Type bl} {{W' : Module W}}
         {X : Type cl} {{X' : Module X}} where

 -- https://en.wikipedia.org/wiki/Bilinear_map
 -- 'Bilinear' is generalized to have a commutative ring instead of a field
 record Bilinear (B : V → W → X) : Type (al ⊔ bl ⊔ cl ⊔ l) where
  field      
   lLinear : (v : V) → moduleHomomorphism (B v)
   rLinear : (w : W) → moduleHomomorphism (λ x → B x w)
 open Bilinear {{...}}

 bilinearLZ : {B : V → W → X} → {{BL : Bilinear B}} → (v : V) → B v Ô ≡ Ô
 bilinearLZ {B = B} v = modHomomorphismZ (B v)
   where instance
       MH : moduleHomomorphism (B v)
       MH = lLinear v

 bilinearRZ : {B : V → W → X} → {{BL : Bilinear B}} → (w : W) → B Ô w ≡ Ô
 bilinearRZ {B = B} w = modHomomorphismZ (λ x → B x w)
   where instance
       MH : moduleHomomorphism λ x → B x w
       MH = rLinear w
