(* autogenerated from sys_verif_code/heap *)
From Perennial.goose_lang Require Import prelude.

Section code.
Context `{ext_ty: ext_types}.

(* heap.go *)

Definition Swap: val :=
  rec: "Swap" "x" "y" :=
    let: "old_y" := ![uint64T] "y" in
    "y" <-[uint64T] (![uint64T] "x");;
    "x" <-[uint64T] "old_y";;
    #().

(* linked_list.go *)

Definition Node := struct.decl [
  "elem" :: uint64T;
  "next" :: ptrT
].

Definition NewList: val :=
  rec: "NewList" <> :=
    let: "l" := ref (zero_val ptrT) in
    ![ptrT] "l".

Definition Node__Insert: val :=
  rec: "Node__Insert" "l" "elem" :=
    struct.new Node [
      "elem" ::= "elem";
      "next" ::= "l"
    ].

Definition Node__Contains: val :=
  rec: "Node__Contains" "l" "elem" :=
    let: "n" := ref_to ptrT "l" in
    let: "found" := ref_to boolT #false in
    Skip;;
    (for: (λ: <>, #true); (λ: <>, Skip) := λ: <>,
      (if: (![ptrT] "n") = #null
      then Break
      else
        (if: (struct.loadF Node "elem" (![ptrT] "n")) = "elem"
        then
          "found" <-[boolT] #true;;
          Break
        else
          "n" <-[ptrT] (struct.loadF Node "next" (![ptrT] "n"));;
          Continue)));;
    ![boolT] "found".

Definition Node__Delete: val :=
  rec: "Node__Delete" "l" "elem" :=
    (if: "l" = #null
    then "l"
    else
      (if: (struct.loadF Node "elem" "l") = "elem"
      then "Node__Delete" (struct.loadF Node "next" "l") "elem"
      else
        struct.storeF Node "next" "l" ("Node__Delete" (struct.loadF Node "next" "l") "elem");;
        "l")).

Definition Node__Append: val :=
  rec: "Node__Append" "l" "other" :=
    (if: "l" = #null
    then "other"
    else
      struct.new Node [
        "elem" ::= struct.loadF Node "elem" "l";
        "next" ::= "Node__Append" (struct.loadF Node "next" "l") "other"
      ]).

(* queue.go *)

Definition Stack := struct.decl [
  "elements" :: slice.T uint64T
].

Definition NewStack: val :=
  rec: "NewStack" <> :=
    struct.new Stack [
      "elements" ::= NewSlice uint64T #0
    ].

Definition Stack__Push: val :=
  rec: "Stack__Push" "s" "x" :=
    struct.storeF Stack "elements" "s" (SliceAppend uint64T (struct.loadF Stack "elements" "s") "x");;
    #().

(* Pop returns the most recently pushed element. The boolean indicates success,
   which is false if the stack was empty. *)
Definition Stack__Pop: val :=
  rec: "Stack__Pop" "s" :=
    (if: (slice.len (struct.loadF Stack "elements" "s")) = #0
    then (#0, #false)
    else
      let: "x" := SliceGet uint64T (struct.loadF Stack "elements" "s") ((slice.len (struct.loadF Stack "elements" "s")) - #1) in
      struct.storeF Stack "elements" "s" (SliceTake (struct.loadF Stack "elements" "s") ((slice.len (struct.loadF Stack "elements" "s")) - #1));;
      ("x", #true)).

Definition Queue := struct.decl [
  "back" :: ptrT;
  "front" :: ptrT
].

Definition NewQueue: val :=
  rec: "NewQueue" <> :=
    struct.mk Queue [
      "back" ::= NewStack #();
      "front" ::= NewStack #()
    ].

Definition Queue__Push: val :=
  rec: "Queue__Push" "q" "x" :=
    Stack__Push (struct.get Queue "back" "q") "x";;
    #().

Definition Queue__emptyBack: val :=
  rec: "Queue__emptyBack" "q" :=
    Skip;;
    (for: (λ: <>, #true); (λ: <>, Skip) := λ: <>,
      let: ("x", "ok") := Stack__Pop (struct.get Queue "back" "q") in
      (if: "ok"
      then
        Stack__Push (struct.get Queue "front" "q") "x";;
        Continue
      else Break));;
    #().

Definition Queue__Pop: val :=
  rec: "Queue__Pop" "q" :=
    let: ("x", "ok") := Stack__Pop (struct.get Queue "front" "q") in
    (if: "ok"
    then ("x", #true)
    else
      Queue__emptyBack "q";;
      let: ("x", "ok2") := Stack__Pop (struct.get Queue "front" "q") in
      ("x", "ok2")).

(* search_tree.go *)

Definition SearchTree := struct.decl [
  "key" :: uint64T;
  "left" :: ptrT;
  "right" :: ptrT
].

Definition NewSearchTree: val :=
  rec: "NewSearchTree" <> :=
    let: "s" := ref (zero_val ptrT) in
    ![ptrT] "s".

Definition singletonTree: val :=
  rec: "singletonTree" "key" :=
    let: "s" := ref (zero_val ptrT) in
    struct.new SearchTree [
      "key" ::= "key";
      "left" ::= ![ptrT] "s";
      "right" ::= ![ptrT] "s"
    ].

Definition SearchTree__Insert: val :=
  rec: "SearchTree__Insert" "t" "key" :=
    (if: "t" = #null
    then singletonTree "key"
    else
      (if: "key" < (struct.loadF SearchTree "key" "t")
      then struct.storeF SearchTree "left" "t" ("SearchTree__Insert" (struct.loadF SearchTree "left" "t") "key")
      else
        (if: (struct.loadF SearchTree "key" "t") < "key"
        then struct.storeF SearchTree "right" "t" ("SearchTree__Insert" (struct.loadF SearchTree "right" "t") "key")
        else #()));;
      "t").

Definition SearchTree__Contains: val :=
  rec: "SearchTree__Contains" "t" "key" :=
    (if: "t" = #null
    then #false
    else
      (if: "key" = (struct.loadF SearchTree "key" "t")
      then #true
      else
        (if: "key" < (struct.loadF SearchTree "key" "t")
        then "SearchTree__Contains" (struct.loadF SearchTree "left" "t") "key"
        else "SearchTree__Contains" (struct.loadF SearchTree "right" "t") "key"))).

End code.
