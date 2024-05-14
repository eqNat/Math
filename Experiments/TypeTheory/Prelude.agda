{-# OPTIONS --hidden-argument-pun #-}

open import Agda.Primitive public

data ℕ : Set where
 Z : ℕ
 S : ℕ → ℕ

_+_ : ℕ → ℕ → ℕ
Z + b = b
S a + b = S (a + b)

data 𝔹 : Set where
 false : 𝔹
 true : 𝔹

xor : 𝔹 → 𝔹 → 𝔹
xor false b = b
xor true false = true
xor true true = false

variable
 l l' al bl cl : Level
 A : Set al
 B : Set bl
 C : Set cl
 n m : ℕ

data ⊥ : Set where

data ⊤ : Set where
 tt : ⊤

¬ : Set l → Set l
¬ A = A → ⊥

_~>_ : A → (A → B) → B
a ~> f = f a
infixl 0 _~>_

_∈_ : A → (A → Set l) → Set l
_∈_ = _~>_
infixr 5 _∈_

_∉_ :  A → (A → Set l) → Set l
_∉_ a X = ¬(a ∈ X)
infixr 5 _∉_

UNREACHABLE : ⊥ → {A : Set l} → A
UNREACHABLE ()

data Σ {A : Set l}(P : A → Set l') : Set (l ⊔ l') where
 _,_ : (x : A) → P x →  Σ P
infixr 5 _,_

fst : {P : A → Set l} → Σ P → A
fst (a , _) = a

snd : {P : A → Set l} → (x : Σ P) → P (fst x)
snd (_ , p) = p

_×_ : Set l → Set l' → Set (l ⊔ l')
A × B = Σ λ (_ : A) → B

data _＋_ (A : Set l) (B : Set l') : Set (l ⊔ l') where
 inl : A → A ＋ B
 inr : B → A ＋ B

orTy : {A B : Set l} → (A ＋ B) → Set l
orTy {A} (inl x) = A
orTy {B} (inr x) = B

orTm : {A B : Set l} → (x : A ＋ B) → orTy x
orTm (inl x) = x
orTm (inr x) = x

data _≡_ {A : Set l} (a : A) : A → Set l where
 refl : a ≡ a
infix 4 _≡_

_≢_ : {A : Set l} → A → A → Set l 
a ≢ b = ¬(a ≡ b)
infix 4 _≢_

cong : {x y : A} → (f : A → B) → x ≡ y → f x ≡ f y
cong f refl = refl

SInjective : ∀{x y : ℕ} → S x ≡ S y → x ≡ y
SInjective {x = x} {y = .x} refl = refl

natDiscrete : (x y : ℕ) → (x ≡ y) ＋ ¬(x ≡ y)
natDiscrete Z Z = inl refl
natDiscrete Z (S y) = inr (λ())
natDiscrete (S x) Z = inr (λ())
natDiscrete (S x) (S y) with natDiscrete x y
... | (inl p) = inl (cong S p)
... | (inr p) = inr λ q → p (SInjective q)

