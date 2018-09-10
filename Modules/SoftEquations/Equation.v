(* =================================================================================== *)
(** * Σ-equations and their models

- Definition of an equation [equation]
- The satisfyability predicate for 1-model [satisfies_equation]
- Definition of 2-model [model_equations]
- Precategory of 2-model [precategory_model_equations]

*)
(* =================================================================================== *)


Require Import UniMath.Foundations.PartD.
Require Import UniMath.Foundations.Propositions.
Require Import UniMath.Foundations.Sets.
Require Import UniMath.CategoryTheory.categories.category_hset.
Require Import UniMath.CategoryTheory.categories.category_hset_structures.
Require Import UniMath.CategoryTheory.Monads.LModules.
Require Import UniMath.CategoryTheory.Categories.
Require Import UniMath.CategoryTheory.Subcategory.Core.
Require Import UniMath.CategoryTheory.Subcategory.Full.
Require Import Modules.Signatures.Signature.
Require Import Modules.SoftEquations.ModelCat.
Require Import Modules.SoftEquations.SignatureOver.

(** Notation for 1-model morphisms *)
Local Notation  "R →→ S" := (rep_fiber_mor R S) (at level 6).


Section Equation.
  (** We fix a 1-signature [Sig] in a category [C] *)
  Context  {C : category} {Sig : signature C}.
  Local Notation REP := (model Sig).

  (** A half-equation between [S1] and [S2] is just a Sig-module morphism between them *)
  Definition half_equation (S1 S2 : signature_over Sig) := signature_over_Mor Sig S1 S2.
  Identity Coercion half_equation_to_sig_mor : half_equation >-> signature_over_Mor.

  (** An equation is given by a pair of Sig-modules and a pair of half-equations between them *)
  Definition equation :=
    ∑ (S1 S2 : signature_over Sig), half_equation S1 S2 × half_equation S1 S2 .

  (** The Sig-module source of an equation *)
  Definition source_equation (e : equation) : signature_over Sig :=
    pr1 e.
  Local Notation σ := source_equation.

  (** The Sig-module target of an equation *)
  Definition target_equation (e : equation) : signature_over Sig :=
    pr1 (pr2 e).
  Local Notation τ := target_equation.

  (** The first half-equation of an equation *)
  Definition halfeq1 (e : equation) : half_equation (source_equation e) (target_equation e) :=
    pr1 (pr2 (pr2 e)).

  (** The second half-equation of an equation *)
  Definition halfeq2 (e : equation) : half_equation (source_equation e) (target_equation e) :=
    pr2 (pr2 (pr2 e)).


  (** The proposition stating that a 1-model [R] satisfies the equation: the R-component of
      both half-equations must be equal *)
  Definition satisfies_equation (e : equation) (R : REP)  : UU := halfeq1 e R = halfeq2 e R.

  (** This statment is hProp *)
  Definition satisfies_equation_isaprop (e : equation) (R : REP)  :
     isaprop (satisfies_equation e R) :=
    homset_property (category_LModule  _ _ ) _ _ _ _.

  Definition satisfies_equation_hp (e : equation) (R : REP) : hProp  :=
    hProppair _ (satisfies_equation_isaprop e R). 

  (** The proposition that a 1-model satisfies a family of equations: it must satisfy
      each of them *)
  Definition satisfies_all_equations_hp {O} (e : O -> equation) R :=
    forall_hProp (fun o => satisfies_equation_hp (e o) R).

  (** Definition of a 2-model: an 1-model [R] satisfying the family of equations [e] *)
  Definition model_equations {O : UU} (e : O -> equation) : UU :=
    ∑ (R : REP), ∏ x, satisfies_equation (e x)  R.

  (** The underlying 1-model of a 2-model *)
  Coercion model_equations_to_model {O e } (R : model_equations (O := O) e ) : REP := pr1 R.

  (** a 2-model satisfies the associated family of equations *)
  Definition model_equations_eq {O} {e : O -> equation} (R : model_equations e) :
    satisfies_all_equations_hp e  R := pr2 R.

  (** The category of 2-model as the full subcategory of 1-models satisfying the required family of equations *)
  Definition precategory_model_equations {O} (e : O -> equation) : precategory :=
    full_sub_precategory (C := rep_fiber_category Sig)
                         (satisfies_all_equations_hp e).
End Equation.


