open Todo

type todoAction =
  | Add(Todo.t)
  | Delete(int)
  | Toggle(int)

let todoListReducer = (state: array<Todo.t>, action: todoAction): array<Todo.t> => {
  switch action {
  | Add(todo) => Array.concat(state, [todo])
  | Delete(index) => Array.filterWithIndex(state, (_, i) => i != index)
  | Toggle(index) =>
    Array.mapWithIndex(state, (currentItem, i) =>
      if i == index {
        {...currentItem, completed: !currentItem.completed}
      } else {
        currentItem
      }
    )
  }
}

@val @scope("localStorage") external getItem: string => Js.Nullable.t<string> = "getItem"
let getItem = (key: string) => getItem(key)->Js.Nullable.toOption

@val @scope("localStorage") external setItem: (string, string) => unit = "setItem"
let setItem = (key: string, value: string) => setItem(key, value)

type storedList = {todos: array<Todo.t>}

@scope("JSON") @val
external parseIntoStoredTodo: string => storedList = "parse"

@scope("JSON") @val
external stringifyStoredTodo: storedList => string = "stringify"

let useTodoListReducer = () => {
  let getInitialValue = () => {
    let storedList = getItem("todoList")

    let parsed = switch storedList {
    | Some(list) => parseIntoStoredTodo(list)
    | None => {todos: []}
    }

    parsed.todos
  }

  let (list, dispatch) = React.useReducer(todoListReducer, getInitialValue())

  React.useEffect1(() => {
    let storedList = stringifyStoredTodo({todos: list})
    setItem("todoList", storedList)
    None
  }, [list])

  (list, dispatch)
}

@react.component
let make = () => {
  let (list, dispatch) = useTodoListReducer()

  let filters = ["all", "active", "completed"]

  let (selectedFilter, setSelectedFilter) = React.useState(_ => "all")

  let visibleTodos = list->Array.filter(todo =>
    switch selectedFilter {
    | "all" => true
    | "active" => !todo.completed
    | "completed" => todo.completed
    | _ => false
    }
  )

  let onSubmitHandler = (event: JsxEvent.Form.t) => {
    event->ReactEvent.Form.preventDefault

    let formInput = ReactEvent.Form.target(event)["todoText"]["value"]

    let text = switch Js.Nullable.toOption(formInput) {
    | Some(text) => text
    | None => ""
    }

    dispatch(Add({text, completed: false}))

    ReactEvent.Form.target(event)["todoText"]["value"] = ""
  }

  let deleteTodo = (~index: int) => dispatch(Delete(index))

  let toggleTodoComplitness = (~index: int) => dispatch(Toggle(index))

  <main
    className="overflow-y-hidden w-full h-screen grid bg-gray-950 text-gray-50 place-items-center p-1">
    <div
      className="flex flex-col items-center justify-center w-full max-w-xl bg-gray-900 rounded">
      <header className="text-2xl font-bold bg-gray-800 px-4 py-2 w-full">
        <div className="flex item-center gap-2">
          {React.array(
            filters->Array.map(filter => {
              let activeColor = filter == selectedFilter ? "bg-blue-600" : "bg-gray-700"

              <Button
                key={filter}
                onClick={_ => setSelectedFilter(_ => filter)}
                className={"text-base w-full " ++ activeColor}>
                {filter->React.string}
              </Button>
            }),
          )}
        </div>
      </header>
      <form
        className="flex flex-col lg:flex-row gap-2 items-center justify-between w-full px-4 py-2"
        onSubmit={onSubmitHandler}>
        <input
          className="w-full px-4 py-2 text-gray-800"
          type_="text"
          name="todoText"
          placeholder="What needs to be done?"
        />
        <Button className="bg-gray-500 w-full lg:w-fit"> {"Add"->React.string} </Button>
      </form>
      <div className="flex flex-col w-full p-4 gap-2">
        {switch visibleTodos {
        | [] => <p className="text-center"> {"No todos yet"->React.string} </p>
        | _ =>
          <ul className="w-full flex flex-col gap-2 h-72 overflow-y-auto">
            {React.array(
              visibleTodos->Array.mapWithIndex((item, index) => {
                <Item key={item.text} index item toggleTodoComplitness deleteTodo />
              }),
            )}
          </ul>
        }}
      </div>
    </div>
  </main>
}
