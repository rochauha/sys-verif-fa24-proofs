(*| # Assignment 1: Part 2 |*)
(*| Remember that part 1 of this assignment is to complete some of the chapters
of Software Foundations (and you should do that first); see main assignment page
for details. |*)

From sys_verif Require Import options.
From stdpp Require Import fin_maps fin_sets gmap.

Open Scope Z_scope.

(*| ## Fixing type errors |*)

Module list_defs.
(*| Here you'll get practice fixing type-checking errors.

The first group of definitions uses the `concat` function, which takes a list of
lists and produces a single list that concatenates all the elements. However,
some of the calls below were written by a slightly confused developer.

For each `Fail Definition` below, fix the definition so it passes the type
checker and remove the `Fail`. You should try to preserve the "intent" of the
original definition; don't just replace the whole thing with something trivial
that works. |*)

Lemma good_concat : concat [[2; 3]; [1]; [4; 5]] = [2; 3; 1; 4; 5].
Proof. reflexivity. Qed.

Fail Definition bad_concat_1 := concat [2; 3].

Fail Definition bad_concat_2 := concat [[2; 3; 4]; concat [[1]]; [[7; 10]]].

(*| Assume that `(x: list nat)` is correct in this definition (that is, don't
change that part). |*)

Fail Definition bad_concat_3 (x: list nat) :=
  concat [x ++ x; [1%nat; 3]; []; [3; 4]%nat].

(*| This next group is a bit tricker, because of how `l !! x` is overloaded, but
we intend to always use it with lists, where `x` should be of type `nat`. |*)

Definition good_lookup_fact (x: list nat): Prop :=
  x !! 3%nat = Some 1%nat.

Fail Definition bad_lookup_1 (x: list bool) :=
  x !! 3%nat = true.

Fail Definition bad_lookup_2 (x: list bool) :=
  x !! 3%nat = Some 7.

Fail Definition bad_lookup_3 (x: list Z) :=
  x !! 3 = Some 4.

End list_defs.

Module map_proofs.

Lemma map_lookup_delete_insert (m: gmap Z nat) (k: Z) (v: nat) :
  delete k (<[ k := v ]> m) !! k = None.
Proof.
  Search ((delete _ _) !! _).
  rewrite lookup_delete //.
Qed.

(*| ### Exercise: finish the following proof and replace [Admitted] with [Qed]. |*)
Lemma map_delete_insert' (m: gmap Z nat) (k: Z) (v: nat) :
  delete k (<[ k := v ]> m) = delete k m.
Proof.
  apply map_eq.
  intros k'.
  destruct (decide (k = k')).
  - subst.
    rewrite !lookup_delete //.
  - (* look for other lookup delete lemmas *)
    rewrite -> !lookup_delete_ne by auto.

Admitted.
End map_proofs.


(*| ## Using the set solver automation |*)

Module set_proofs.
(*| 
### Exercise

`set_solver` on its own fails on the proof below. For this exercise, finish
the proof by `assert`ing the right fact, proving it, then calling
`set_solver`. This is good practice for thinking through why the property
holds and what the automation is missing.

(In the future, we won't restrict what tactics you can use to prove theorems,
but early on it's good for practice.)
|*)
Lemma set_property3 (s1 s2: gset Z) :
  (∀ x, x ∈ s1 → 3 < x) →
  (s1 ∪ s2) ∖ {[2]} = s1 ∪ (s2 ∖ {[2]}).
Proof.
Admitted.
(*| An alternate proof is to use `set_solver by lia`, a feature of the set
  solver that extends the automation with the ability to call `lia` when needed.
  This extra power is enough to do the proof above. |*)
Lemma set_property3_alt_proof (s1 s2: gset Z) :
  (∀ x, x ∈ s1 → 3 < x) →
  (s1 ∪ s2) ∖ {[2]} = s1 ∪ (s2 ∖ {[2]}).
Proof.
  set_solver by lia.
Qed.

End set_proofs.


(*| ## Verification of a functional interval library |*)

(*| In this last sub-section, you'll prove the correctness of some operations on
intervals. |*)

Module interval_verification.

Record interval :=
  mkInterval { low: Z; high: Z }.

(*| All of the interval specifications will be proven in terms of `in_interval` below, which says
when `x: Z` is an element of an interval.

You should think of an interval as abstractly representing a set of integers,
and this definition defines that set. In the future, the gap between what the
code and the abstraction will be larger (e.g., the code won't have unbounded
integers at all), so it'll be easier to see what the difference is. On the other
hand, because the code and the spec are closely related in this example, the
specs and proofs are quite short.
|*)

Instance in_interval : ElemOf Z interval :=
  (* this gets printed as [low i ≤ x ≤ high i], which is just a notation *)
  λ x i, low i <= x ∧ x <= high i.

(*| Making the `in_interval` definition an `Instance` of `ElemOf` extends the
`∈` notation to have a meaning for our intervals, "overloading" its more common
meaning as element-of for sets.

This is what it looks like to use `in_interval` in a theorem.
Notice that we unfold `elem_of`, which is what the `∈` notation is defined as,
and then we can unfold `in_interval`.

This unfolding is required for `lia` to work, since otherwise it doesn't
understand that `x ∈ i` is a useful arithmetic fact.
|*)
Lemma in_interval_fact x (i: interval) :
  x ∈ i → low i <= x.
Proof.
  rewrite /elem_of.
  rewrite /in_interval.
  lia.
Qed.

(*| First, we give you definitions of `union` and `intersect` and their
specifications. Prove the implementations meet these specifications. |*)

Definition union (i1 i2: interval): interval :=
  {|  low := Z.min (low i1) (low i2);
      high := Z.max (high i1) (high i2);
  |}.

Definition intersect (i1 i2: interval): interval :=
  {|  low := Z.max (low i1) (low i2);
      high := Z.min (high i1) (high i2);
  |}.

Lemma union_spec x i1 i2 :
  x ∈ i1 ∨ x ∈ i2 → x ∈ union i1 i2.
Proof.
  rewrite /union /elem_of /in_interval /=.
  intros Hin.
  destruct Hin as [Hin1 | Hin2].
  - lia.
  - lia.
Qed.

Lemma intersect_spec x i1 i2 :
  x ∈ intersect i1 i2 → x ∈ i1 ∧ x ∈ i2.
Proof.
  rewrite /intersect /elem_of /in_interval /=.
  intros Hin.
  split.
  - lia.
  - lia.
Qed.

(*| Aside: we proved specifications only in one direction; do you see why the
other direction isn't true? |*)

(* Next, implement `is_empty` and prove the specification below for it. *)
Definition is_empty (i: interval): Prop :=
  True.

(* [x ∉ i] is just notation for [~ (x ∈ i)] (and this is notation for [x ∈ i →
False]) *)
Lemma is_empty_spec i :
  is_empty i ↔ (∀ x, x ∉ i).
Proof.
Admitted.

(*| `contains` is supposed to be true when `i1` is completely inside `i2`. |*)
Definition contains i1 i2 :=
  low i2 <= low i1 ∧ high i1 <= high i2.

(*| The specification below is false. Add the right precondition to make it true. |*)

Lemma contains_spec i1 i2 :
    contains i1 i2 ↔ (∀ x, x ∈ i1 → x ∈ i2).
Proof.
Admitted.

(*| As a sanity check of your `contains_spec` precondition, we've used that
theorem to prove a specific `contains` fact. This proof won't go through if, for
example, you add the precondition `False`, which we consider to be an incorrect
solution. You should not need to change the proof below. |*)
Lemma contains_spec_check :
  contains (mkInterval 2 4) (mkInterval 2 7).
Proof.
  apply contains_spec; rewrite /elem_of /in_interval; simpl; lia.
Qed.


End interval_verification.
