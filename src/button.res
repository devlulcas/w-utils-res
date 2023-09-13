@react.component
let make = (
  ~children: React.element,
  ~onClick: option<unit => unit>=?,
  ~className: option<string>=?,
) => {
  let appendedClassName = className->Belt.Option.getWithDefault("")

  <button
    className={"px-4 py-2 rounded hover:bg-opacity-50 " ++ appendedClassName}
    onClick={_ =>
      switch onClick {
      | Some(onClick) => onClick()
      | None => ()
      }}>
    {children}
  </button>
}
