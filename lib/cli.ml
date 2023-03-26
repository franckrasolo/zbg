open Core

(* Custom types *)

let to_force_flag (flag : bool) =
  if flag then Git.Force else Git.NoForce

(* Commands *)

let cmd_clear =
  Command.basic
    ~summary:"Clear all local changes without the ability to recover"
    (let%map_open.Command
      force = flag "f" no_arg ~doc:"Clear forcefully without asking any questions"
    in fun () -> Git.clear (to_force_flag force))

let cmd_new =
  Command.basic
    ~summary:"Create a new branch <login>/[description]"
    (let%map_open.Command description = anon ("description" %: string) in
      fun () ->
        printf "git checkout -b <login>/%s\n%!" description)

let cmd_push =
  Command.basic
    ~summary:"Push the current branch to origin"
    (let%map_open.Command
      force = flag "f" no_arg ~doc:"Push forcefully and override changes"
    in fun () -> Git.push (to_force_flag force))

let cmd_rebase =
  Command.basic
    ~summary:"Rebase current local branch on top of origin/[branch]"
    (let%map_open.Command
      branch = anon (maybe ("branch" %: string))
    in fun () -> Git.rebase branch)

let cmd_stash =
  Command.basic
    ~summary:"Stash all local changes"
    (let%map_open.Command
      message = anon (maybe ("message" %: string))
    in fun () -> Git.stash message)

let cmd_status =
  Command.basic
    ~summary:"Show pretty current status"
    (Command.Param.return
      (fun () -> Process.proc "git status")
    )

let cmd_switch =
  Command.basic
    ~summary:"Switch to [branch] and sync it with origin"
    (let%map_open.Command
      branch = anon (maybe_with_default "main" ("branch" %: string))
    in fun () -> Git.switch branch)

let cmd_sync =
  Command.basic
    ~summary:"Sync local branch with the remote branch"
    (let%map_open.Command
      force = flag "f" no_arg ~doc:"Sync forcefully by overriding local version with the remote one instead of rebasing"
    in fun () -> Git.sync (to_force_flag force))

let cmd_unstash =
  Command.basic
    ~summary:"Unstash last stashed changes"
    (Command.Param.return
      (fun () -> Git.unstash ())
    )

(* Grouping all commands *)

let command =
  Command.group
    ~summary:"Easier git workflow"
    [ "clear", cmd_clear
    ; "new", cmd_new
    ; "push", cmd_push
    ; "rebase", cmd_rebase
    ; "stash", cmd_stash
    ; "status", cmd_status
    ; "switch", cmd_switch
    ; "sync", cmd_sync
    ; "unstash", cmd_unstash
    ]

(*
TODO:

- commit
- status
- log
- new
- tag
- uncommit
- fix
- amend

With API:

- issue
- milestone
*)