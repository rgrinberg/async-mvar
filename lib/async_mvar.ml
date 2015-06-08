open Core_kernel.Std
open Async_kernel.Std

type 'a t = {
  mutable contents : 'a option;
  writers : ('a * unit Ivar.t) Queue.t;
  readers : 'a Ivar.t Queue.t;
}

let create_empty () =
  { contents = None;
    writers = Queue.create ();
    readers = Queue.create () }

let create a =
  { contents = Some a;
    writers = Queue.create ();
    readers = Queue.create () }

let put t a =
  match t.contents with
  | None ->
    begin match Queue.dequeue t.readers with
    | None -> t.contents <- Some a
    | Some w -> Ivar.fill w a
    end;
    return ()
  | Some _ ->
    let ivar = Ivar.create () in
    Queue.enqueue t.writers (a, ivar);
    Ivar.read ivar

let take t =
  match t.contents with
  | Some v ->
    begin match Queue.dequeue t.writers with
    | Some (v', w) ->
      t.contents <- Some v';
      Ivar.fill w ()
    | None -> t.contents <- None
    end;
    return v
  | None ->
    let ivar = Ivar.create () in
    Queue.enqueue t.readers ivar;
    Ivar.read ivar

