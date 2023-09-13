open Todo

@react.component
let make = (
  ~index: int,
  ~item: Todo.t,
  ~toggleTodoComplitness: (~index: int) => unit,
  ~deleteTodo: (~index: int) => unit,
) => {
  <li className="flex items-center justify-between px-2 py-1 bg-gray-600 rounded">
    <div className="flex items-center gap-2">
      <input
        type_="checkbox" checked={item.completed} onChange={_ => toggleTodoComplitness(~index)}
      />
      <span className={item.completed ? "line-through" : "underline"}>
        {item.text->React.string}
      </span>
    </div>
    <button className="px-2 py-1 rounded hover:bg-gray-700" onClick={_ => deleteTodo(~index)}>
      {"Delete"->React.string}
    </button>
  </li>
}
