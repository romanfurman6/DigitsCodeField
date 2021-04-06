# DigitsCodeField
Simple UIView for code digits entering and pasting

## Usage

```
// Init
init(maxDigitsCount: Int = 6)

// Update state
func updateUI(with state: State)

enum State {
    case isEditing(Bool)
    case isValid(Bool)
}
```

## Demo

<img src="https://user-images.githubusercontent.com/22365403/113734858-60862700-9704-11eb-9296-cb70db2c4f59.gif" alt="demo" width="376" height="808">
