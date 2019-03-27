(* client_example.ml *)
open Lwt
open Cohttp
open Cohttp_lwt_unix

let makestring =
	let () = print_endline "Enter stock ticker " in
	let ticker = read_line() in
	"https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=" ^ ticker ^ "&interval=5min&apikey=GS4ESAYXG0G6D66Q"

let body =
  Client.get (Uri.of_string makestring) >>= fun (resp, body) ->
  let code = resp |> Response.status |> Code.code_of_status in
  Printf.printf "Response code: %d\n" code;
  Printf.printf "Headers: %s\n" (resp |> Response.headers |> Header.to_string);
  body |> Cohttp_lwt.Body.to_string >|= fun body ->
  Printf.printf "Body of length: %d\n" (String.length body);
  body

let () =
  let body = Lwt_main.run body in
  print_endline ("Received body\n" ^ body)
