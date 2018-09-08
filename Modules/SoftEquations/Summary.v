(** Summary of the formalization (kernel)

Tip: The Coq command [About ident] prints where the ident was defined
 *)


Require Import UniMath.Foundations.PartD.

Require Import UniMath.CategoryTheory.Monads.Monads.
Require Import UniMath.CategoryTheory.Monads.LModules. 
Require Import UniMath.CategoryTheory.SetValuedFunctors.
Require Import UniMath.CategoryTheory.HorizontalComposition.
Require Import UniMath.CategoryTheory.functor_categories.
Require Import UniMath.CategoryTheory.categories.category_hset.
Require Import UniMath.CategoryTheory.categories.category_hset_structures.

Require Import UniMath.CategoryTheory.Categories.
Require Import UniMath.Foundations.Sets.
Require Import UniMath.CategoryTheory.Epis.
Require Import UniMath.CategoryTheory.EpiFacts.

Require Import Modules.Prelims.lib.
Require Import Modules.Prelims.quotientmonad.
Require Import Modules.Prelims.quotientmonadslice.
Require Import Modules.Signatures.Signature.
Require Import Modules.SoftEquations.ModelCat.
Require Import Modules.Prelims.modules.

Require Import Modules.SoftEquations.quotientrepslice.
Require Import Modules.SoftEquations.SignatureOver.
Require Import Modules.SoftEquations.Equation.
Require Import Modules.SoftEquations.quotientrepslice.
Require Import Modules.SoftEquations.quotientequation.

Require Import UniMath.CategoryTheory.limits.initial.
Require Import Modules.SoftEquations.InitialEquationRep.

Require Import UniMath.CategoryTheory.DisplayedCats.Auxiliary.
Require Import UniMath.CategoryTheory.DisplayedCats.Core.
Require Import UniMath.CategoryTheory.DisplayedCats.Constructions.
Require Import UniMath.CategoryTheory.DisplayedCats.Fibrations.

Require Import UniMath.CategoryTheory.Subcategory.Core.
Require Import UniMath.CategoryTheory.Subcategory.Full.

Local Notation MONAD := (Monad SET).
Local Notation MODULE R := (LModule R SET).

(**
The command:

Check (x ::= y) 

succeeds if and only if [x] is convertible to [y]

*)
Notation  "x ::= y"  := ((idpath _ : x = y) = idpath _) (at level 70, no associativity).

Fail Check (true ::= false).
Check (true ::= true).

(** *******************

 Definition of a signature

The more detailed definition can be found in Signature/Signature.v

 ****** *)

Check (
    signature_data (C := SET) ::=
      (** a signature assigns to each monad a module over it *)
      ∑ F : (∏ R : MONAD, MODULE R),
            (** a signature sends monad morphisms on module morphisms *)
            ∏ (R S : MONAD) (f : Monad_Mor R S), LModule_Mor _ (F R) (pb_LModule f (F S))
  ).

(** Functoriality for signatures:
- [signature_idax] means that # F id = id
- [signature_compax] means that # F (f o g) = # F f o # F g
 *)
Check (∏ (F : signature_data (C:= SET)),
       is_signature  F ::=
         (signature_idax F × signature_compax F)).

Check (signature SET ::= ∑ F : signature_data, is_signature F).


Local Notation SIGNATURE := (signature SET).
(** *******************

 Definition of a model of a signature

The more detailed definitions of models can be found in Signatures/Signature.v
The more detailed definitions of model morphisms can be found in SoftSignatures/ModelCat.v

 ****** *)

(** The tautological module R over the monad R *)
Local Notation Θ := tautological_LModule.

Check (∏ (R : MONAD), (Θ R : functor _ _) ::= R).

(**
A model of a signature S is a monad R with a module morphism from S R to R, called an action.
*)
Check (∏ (S : SIGNATURE), model S ::=
    ∑ R : MONAD, LModule_Mor R (S R) (Θ R)).

(** the action of a model *)
Check (∏ (S : SIGNATURE) (M : model S),
       model_τ M ::= pr2 M).

(**
Given a signature S, a model morphism is a monad morphism commuting with the action
*)
Check (∏ (S : SIGNATURE) (M N : model S),
       rep_fiber_mor M N  ::=
         ∑ g:Monad_Mor M N,
             ∏ c : SET, model_τ M c · g c = ((#S g)%ar:nat_trans _ _) c ·  model_τ N c ).


Local Notation  "R →→ S" := (rep_fiber_mor  R S) (at level 6).


(** The category of 1-models *)
Check (∏ (S : SIGNATURE),
       rep_fiber_precategory S ::=
         (precategory_data_pair
            (** the object and morphisms of the category *)
            (precategory_ob_mor_pair (model S) rep_fiber_mor)
            (** the identity morphism *)
            (λ R, rep_fiber_id R)
            (** Composition *)
            (λ M N O , rep_fiber_comp)
           ,,
             (** This second component is a proof that the axioms of categories are satisfied *)
             is_precategory_rep_fiber_precategory_data S)
         ).


(** *******************

 Definition of an S-signature, or that of a signature over a 1-signature S

The more detailed definitions can be found in SoftSignatures/SignatureOver.v

 ****** *)

(**
a signature over a 1-sig S assigns functorially to any model of S a module over the underlying monad.
*)
Check (∏ (S : SIGNATURE),
       signature_over S ::=
         ∑ F :
           (** model -> module over the monad *)
           (∑ F : (∏ R : model S, MODULE R),
                  (** model morphism -> module morphism *)
                  ∏ (R S : model S) (f : R →→ S),
                  LModule_Mor _ (F R) (pb_LModule f (F S))),

               (** functoriality conditions (see SignatureOver.v) *)
               is_signature_over S F).

Local Notation "F ⟹ G" := (signature_over_Mor _ F G) (at level 39).

(**
a morphism of oversignature is a natural transformation
*)
Check (∏ (S : SIGNATURE)
         (F F' : signature_over S),
       signature_over_Mor S F F' ::=
         (** a family of module morphism from F R to F' R for any model R *)
         ∑ (f : (∏ R : model S, LModule_Mor R (F R) (F' R))),
         (** subject to naturality conditions (see SignatureOver.v for the full definition) *)
           is_signature_over_Mor S F F' f
      ).

(** Definition of an oversignature which preserve epimorphisms in the category of natural transformations
(Cf SoftEquations/quotientequation.v *)
Check (∏ (S : SIGNATURE)
         (F : signature_over S),
       isEpi_overSig F ::=
        ∏ R S (f : R →→ S),
                   isEpi (C := [SET, SET]) (f : nat_trans _ _) ->
                   isEpi (C := [SET, SET]) (# F f : nat_trans _ _)%sigo
       ).

(** Definition of a soft-over signature (SoftEquations/quotientequation.v) 

It is a signature Σ such that for any model R, and any family of model morphisms 
(f_j : R --> d_j), the following diagram can be completed in the category
of natural transformations:

<<<
           Σ(f_j)
    Σ(R) ----------->  Σ(d_j)
     |
     |
     |
 Σ(π)|
     |
     V
    Σ(S)

>>>

where π : R -> S is the canonical projection (S is R quotiented by the family (f_j)_j

 *)
Check (∏ (S : SIGNATURE)
         (F : signature_over S)
         (** The axiom of choice is necessary to make quotient monad *)
         (ax_choice : AxiomOfChoice.AxiomOfChoice_surj)
         (** S preserves epimorphisms of monads *)
         (isEpi_sig : ∏ (R R' : MONAD)
                        (f : Monad_Mor R R'),
                        (isEpi (C:= [SET,SET]) (f : nat_trans _ _) ->
                      isEpi (C:= [SET,SET]) ((#S f)%ar : nat_trans _ _))),
       isSoft ax_choice isEpi_sig F
       ::=
         (∏ (R : model S)
            (J : UU)(d : J -> (model S))(f : ∏ j, R →→ (d j))
            X (x y : (F R X : hSet))
            (pi := projR_rep S isEpi_sig ax_choice d f),
          (∏ j, (# F (f j))%sigo X x  = (# F (f j))%sigo X y )
          -> (# F pi X x)%sigo = 
            (# F pi X y)%sigo  )
       ).





(* **********

Definition of Equations. See SoftEquations/Equation.v

************ **)

(** An equation over a signature S is a pair of two signatures over S, and a signature over morphism between them *)
Check (∏ (S : SIGNATURE),
       equation (Sig := S) ::=
    ∑ (S1 S2 : signature_over S), S1 ⟹ S2 × S1 ⟹ S2).

(** Soft equation: the domain must be an epi over-signature, and the target
    must be soft (SoftEquations/quotientequation)
 *)
Check (∏ (S : SIGNATURE)
         (** The axiom of choice is necessary to make quotient monad *)
         (ax_choice : AxiomOfChoice.AxiomOfChoice_surj)
         (** S preserves epimorphisms of monads *)
         (isEpi_sig : ∏ (R R' : MONAD)
                        (f : Monad_Mor R R'),
                        (isEpi (C:= [SET,SET]) (f : nat_trans _ _) ->
                      isEpi (C:= [SET,SET]) ((#S f)%ar : nat_trans _ _))),

       soft_equation ax_choice isEpi_sig ::=
        ∑ (e : equation), isSoft ax_choice isEpi_sig (pr1 (pr2 e)) × isEpi_overSig (pr1 e)).
(** 
Definition of the category of 2-models of a 1-signature with a family of equation.

It is the full subcategory of 1-models satisfying all the equations

See SoftEquations/Equation.v for details

*)

(** a model R satifies the equations if the R-component of the two over-signature morphisms are equal for any
    equation of the family *)
Check (∏ (S : SIGNATURE)
         (** a family of equations indexed by O *)
         O (e : O -> equation (Sig := S))
         (R : model S)
       ,
    satisfies_all_equations_hp e R ::=
         (
           (∏ (o : O),
            (** the first half-equation of the equation [e o] *)
            pr1 (pr2 (pr2 (e o))) R =
            (** the second half-equation of the equation [e o] *)
            pr2 (pr2 (pr2 (e o))) R)
          ,,
            (** this second component is a proof that this predicate is hProp *)
            _)
           ).

(** The category of 2-models  is the full subcategory of the category [rep_fiber_category S]
  satisfying all the equations *)
Check (∏ (S : SIGNATURE)
         (** a family of equations indexed by O *)
         O (e : O -> equation (Sig := S)),

   precategory_model_equations e ::=
    full_sub_precategory (C := rep_fiber_precategory S)
                         (satisfies_all_equations_hp e)).


(** *********************** 

Our main result : if a 1-signature Σ generates a syntax, then the 2-signature over Σ
consisting of any family of soft equations over Σ also generates a syntax
(SoftEquations/InitialEquationRep.v)

*)
Check (soft_equations_preserve_initiality :
         (** The axiom of choice is needed for quotient monads/models *)
         ∏ (choice : AxiomOfChoice.AxiomOfChoice_surj)
           (** The 1-signature *)
           (Sig : SIGNATURE)
           (** The 1-signature must be an epi-signature *)
           (epiSig : ∏ (R S : Monad SET) (f : Monad_Mor R S),
                     isEpi (C := [SET, SET]) (f : nat_trans R S)
                     → isEpi (C := [SET, SET])
                             ((# Sig)%ar f : nat_trans (Sig R)  (pb_LModule f (Sig S))))
           (** A family of equations *)
           (O : UU) (eq : O → soft_equation choice epiSig),
         (** If the category of 1-models has an initial object, .. *)
         Initial (rep_fiber_category Sig)
        (** .. then the category of 2-models has an initial object *)
         → Initial (precategory_model_equations (λ x : O, eq x))).

