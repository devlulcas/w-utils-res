open Todo

@react.component
let make = (
  ~index: int,
  ~item: Todo.t,
  ~toggleTodoComplitness: (~index: int) => unit,
  ~deleteTodo: (~index: int) => unit,
) => {
  let id = React.useId()

  let labelStatusStyle = item.completed ? "line-through bg-gray-800" : "bg-gray-700"
  let buttonStatusStyle = item.completed
    ? "bg-blue-700/50 hover:bg-blue-500"
    : "bg-blue-700 hover:bg-blue-500"

  <li className="flex items-center bg-gray-300 h-fit">
    <label
      htmlFor={id}
      className={"cursor-pointer h-full w-full px-2 py-1 border-2 border-blue-950/25 focus-within:border-blue-600/50 " ++
      labelStatusStyle}>
      <input
        id={id}
        type_="checkbox"
        checked={item.completed}
        onChange={_ => toggleTodoComplitness(~index)}
        className="sr-only"
      />
      <span className="break-words whitespace-break-spaces"> {item.text->React.string} </span>
    </label>
    <button
      className={"outline-none border-2 border-blue-950/25 focus:border-blue-600/50 px-2 h-full " ++
      buttonStatusStyle}
      onClick={_ => deleteTodo(~index)}>
      {"Delete"->React.string}
    </button>
  </li>
}
