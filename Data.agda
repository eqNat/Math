open import algebra

-- True is defined as a type with one term
data True : Set where
  void : True

data Bool : Set where
  yes : Bool
  no : Bool

not : Bool → Bool
not yes = no
not no = yes

xor : Bool → Bool → Bool
xor yes b = not b
xor no b = b

and : Bool → Bool → Bool
and yes b = b
and no _ = no

-- Peano natural numbers
data nat : Set where
  Z : nat
  S : nat → nat
-- 'Z' is 0
-- 'S Z' is 1
-- 'S (S Z)' is 2
-- 'S (S (S Z))' is 3
-- ...
-- 'S n' is n + 1

variable
  n m : nat

add : nat → nat → nat
add Z b = b
add (S a) b = S (add a b)

mult : nat → nat → nat
mult Z b = Z
mult (S a) b = add b (mult a b)

Sout : (n m : nat) → add n (S m) ≡ S (add n m)
Sout Z m = refl
Sout (S n) m = cong S (Sout n m)

addZ : (n : nat) → add n Z ≡ n
addZ Z = refl
addZ (S n) = cong S (addZ n)

instance
  natAddCom : Commutative add
  natAddCom = record { commutative = addCom }
   where
    addCom : (a b : nat) → add a b ≡ add b a
    addCom a Z = addZ a
    addCom a (S b) = eqTrans (Sout a b) (cong S (addCom a b))
  natAddAssoc : Associative add
  natAddAssoc = record { associative = addAssoc }
    where
    addAssoc : (a b c : nat) → add a (add b c) ≡ add (add a b) c
    addAssoc Z b c = refl
    addAssoc (S a) b c = cong S (addAssoc a b c)
  natAddMonoid : monoid add Z
  natAddMonoid = record { lIdentity = λ a → refl ; rIdentity = addZ }
  natAddCM : cMonoid add Z
  natAddCM = record {}

addOut : (n m : nat) → mult n (S m) ≡ add n (mult n m)
addOut Z m = refl
addOut (S n) m = cong S $ add m (mult n (S m)) ≡⟨ cong (add m) (addOut n m) ⟩
                         add m (add n (mult n m)) ≡⟨ associative m n (mult n m) ⟩
                         add (add m n) (mult n m) ≡⟨ cong2 add (commutative m n) refl ⟩
                         add (add n m) (mult n m) ≡⟨ sym (associative n m (mult n m)) ⟩
                       add n (add m (mult n m)) ∎

multZ : (n : nat) → mult n Z ≡ Z
multZ Z = refl
multZ (S n) = multZ n

natMultDist : (a b c : nat) → add (mult a c) (mult b c) ≡ mult (add a b) c
natMultDist Z b c = refl
natMultDist (S a) b c = add (add c (mult a c)) (mult b c) ≡⟨ sym (associative c (mult a c) (mult b c)) ⟩
                        add c (add (mult a c) (mult b c)) ≡⟨ cong (add c) (natMultDist a b c) ⟩
                        add c (mult (add a b) c) ∎

instance
  natMultCom : Commutative mult
  natMultCom = record { commutative = multCom }
   where
    multCom : (a b : nat) → mult a b ≡ mult b a
    multCom a Z = multZ a
    multCom a (S b) = eqTrans (addOut a b) (cong (add a) (multCom a b))
  natMultAssoc : Associative mult
  natMultAssoc = record { associative = multAssoc }
    where
    multAssoc : (a b c : nat) → mult a (mult b c) ≡ mult (mult a b) c
    multAssoc Z b c = refl
    multAssoc (S a) b c = eqTrans (cong (add (mult b c)) (multAssoc a b c)) (natMultDist b (mult a b) c)
  natMultMonoid : monoid mult (S Z)
  natMultMonoid = record { lIdentity = addZ ; rIdentity = λ a → eqTrans (commutative a (S Z)) (addZ a) }
  natMultCM : cMonoid mult (S Z)
  natMultCM = record {}
  natSemiRing : SemiRing nat 
  natSemiRing =
   record
      { zero = Z
      ; one = (S Z)
      ; _+_ = add
      ; _*_ = mult
      ; lDistribute = λ a b c → mult a (add b c)          ≡⟨ commutative a (add b c) ⟩
                                mult (add b c) a          ≡⟨ sym (natMultDist b c a) ⟩
                                add (mult b a) (mult c a) ≡⟨ cong2 add (commutative b a) (commutative c a)⟩
                                add (mult a b) (mult a c) ∎
      ; rDistribute = λ a b c → sym (natMultDist b c a)
      }

-- vector definition
-- `[ Bool ^ n ]` is a vector of booleans with length `n`
data [_^_] (A : Set l) : nat → Set l where
  [] : [ A ^ Z ]
  _::_ : {n : nat} → A → [ A ^ n ] → [ A ^ S n ]
infixr 5 _::_

Matrix : Set l → nat → nat → Set l
Matrix A n m = [ [ A ^ n ] ^ m ]

zip : (A → B → C) → {n : nat} → [ A ^ n ] → [ B ^ n ] → [ C ^ n ]
zip f {n = Z} _ _ = []
zip f {n = S n} (a :: as) (b :: bs) = (f a b) :: zip f as bs

instance
  fvect : functor {al = l} λ A → [ A ^ n ]
  fvect = record { map = rec ; compPreserve = compPreserveAux ; idPreserve = idPreserveAux }
   where
    rec : (A → B) → [ A ^ n ] → [ B ^ n ]
    rec f [] = []
    rec f (x :: v) = f x :: rec f v
    compPreserveAux : (f : B → C) (g : A → B) (x : [ A ^ n ]) → rec (f ∘ g) x ≡ (rec f ∘ rec g) x
    compPreserveAux f g [] = refl
    compPreserveAux f g (x :: x') = cong (f (g x) ::_) (compPreserveAux f g x')
    idPreserveAux : (x : [ A ^ n ]) → rec id x ≡ id x
    idPreserveAux [] = refl
    idPreserveAux (x :: x') = cong (x ::_) (idPreserveAux x')

zeroV : {{SemiRing A}} → (n : nat) → [ A ^ n ]
zeroV Z = []
zeroV (S n) = zero :: (zeroV n)

vOne : {{SemiRing A}} → (n : nat) → [ A ^ n ]
vOne Z = []
vOne (S n) = one :: (vOne n)

addv : {{SemiRing A}} → {n : nat} → [ A ^ n ] → [ A ^ n ] → [ A ^ n ]
addv = zip _+_

negv : {{Ring A}} → {n : nat} → [ A ^ n ] → [ A ^ n ]
negv = map neg

multv : {{SemiRing A}} → {n : nat} → [ A ^ n ] → [ A ^ n ] → [ A ^ n ]
multv = zip _*_

scaleV : {{SemiRing A}} → {n : nat} → A → [ A ^ n ] → [ A ^ n ]
scaleV a = map (_* a)

diag : {{SemiRing A}} → {n m : nat} → [ A ^ m ] → Matrix A n m  → Matrix A n m
diag = zip scaleV

foldr : (A → B → B) → B → {n : nat} → [ A ^ n ] → B
foldr f b [] = b
foldr f b (a :: v) = f a (foldr f b v)

foldv : (A → A → A) → {n : nat} → [ A ^ S n ] → A
foldv f (a :: []) = a
foldv f (a :: b :: v) = f a (foldv f (b :: v))

addvId : {n : nat} → {{R : Ring A}} → (v : [ A ^ n ]) → addv v (zeroV n) ≡ v
addvId {n = Z} [] = refl
addvId {n = S n} (x :: v) = cong2 _::_ (rIdentity x) (addvId v)

car : {n : nat} → [ A ^ S n ] → A
car (x :: _) = x

cdr : {n : nat} → [ A ^ S n ] → [ A ^ n ]
cdr (_ :: v) = v

-- Matrix Transformation
MT : {n m : nat} → {{R : SemiRing A}} → Matrix A n m → [ A ^ m ] → [ A ^ n ]
MT {n = n} M v = foldr addv (zeroV n) (diag v M)

-- Matrix Multiplication
mMult : {{R : SemiRing A}} → {a b c : nat} → Matrix A a b → Matrix A b c → Matrix A a c
mMult M = map (MT M)

transpose : {n m : nat} -> Matrix A n m -> Matrix A m n
transpose {n = Z} M = []
transpose {n = S n} M = map car M :: transpose (map cdr M)