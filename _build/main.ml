open Lwt
open Cohttp
open Cohttp_lwt_unix
open Opium.Std

type person = {
  name: string;
  age: int;
}

let body =
  Client.get (Uri.of_string "https://www.reddit.com/") >>= fun (resp, body) ->
  let code = resp |> Cohttp.Response.status |> Code.code_of_status in
  Printf.printf "Response code: %d\n" code;
  Printf.printf "Headers: %s\n" (resp |> Cohttp.Response.headers |> Header.to_string);
  body |> Cohttp_lwt.Body.to_string >|= fun body ->
  Printf.printf "Body of length: %d\n" (String.length body);
  body

let json_of_person {id}=
  let open Ezjsonm in
    dict["id", (string id)]

let print_param = put "/hello/:name" begin fun req ->
  `String ("Hello " ^ param req "name") |> respond'
end

let print_person = get "/person/:name/:age" begin fun req ->
(*  let person = {
    name = param req "name";
    age = "age" |> param req |> int_of_string;
  } in
  `Json (person |> json_of_person) |> respond'
*)
  let body = Lwt_main.run body in
  `Json body |> respond'
end

let _ =
  App.empty
  |> print_param
  |> print_person
  |> App.run_command
