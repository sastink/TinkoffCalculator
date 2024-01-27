import UIKit

enum CalculationError : Error {
    case divideByZero
}

/// все поддерживаемые операции калькулятора
enum Operation: String {
    case add = "+"
    case substract = "-"
    case multiply = "x"
    case divide = "/"
    
    func calculate(_ number1: Double, _ number2: Double) throws -> Double {
        switch self {
        case .add:
            return number1 + number2
        case .substract:
            return number1 - number2
        case .multiply:
            return number1 * number2
        case .divide:
            if number2 == 0 {
                throw CalculationError.divideByZero
            }
            
            return number1 / number2
        }
    }
}

/// один элемент истории: значение и операция
enum CalculationHistoryItem{
    case number(Double)
    case operation(Operation)
}

final class ViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    
    /// массив истории вычислений
    private var calculationHistory: [CalculationHistoryItem] = []
    
    // преобразователь чисел в строку и наоборот
    private lazy var numberFormatter : NumberFormatter = {
        let numberFormatter = NumberFormatter()
        
        numberFormatter.usesGroupingSeparator = false
        numberFormatter.locale = Locale(identifier: "ru_RU")
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter
    }()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        // сбрасываем в ноль
        resetLabelText()
    }
}

// MARK: - Private methods - 

private extension ViewController {
    
    func calculate() throws -> Double {
        guard case .number(let firstNumber) = calculationHistory[0] else { return 0 }
        
        var currentResult = firstNumber
        
        // в массиве начиная со второго элемента должны быть пары: операция и число
        for index in stride(from: 1, to: calculationHistory.count - 1, by: 2 ) {
            guard
                case .operation(let operation) = calculationHistory[index],
                case .number(let number) = calculationHistory[index + 1]
            else { break }
            currentResult = try operation.calculate(currentResult, number)
        }
        
        return currentResult
    }
    
    func resetLabelText() {
        label.text = "0"
    }
}

// MARK: - Actions -

private extension ViewController {
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        guard let buttonText = sender.currentTitle else { return }
        
        // знак дробной части можем использовать только раз
        if buttonText == "," && label.text?.contains(",") == true {
            return
        }
                
        if label.text == "0" || label.text == "Ошибка" {
            label.text = buttonText
        } else {
            // добавляем символы к тексту, который уже есть
            label.text?.append(buttonText)
        }
    }
    
    @IBAction func operationButtonPressed(_ sender: UIButton) {
        // получаем операцию
        guard
            let buttonText = sender.currentTitle,
            let buttonOperation = Operation(rawValue: buttonText)
        else { return }
        
        // текст есть и он преобразовывается в число
        guard
            let labelText = label.text,
            let labelNumber = numberFormatter.number(from: labelText)?.doubleValue
        else { return }
        
        // последовательно сохраняем число, потом операцию
        calculationHistory.append(.number(labelNumber))
        calculationHistory.append(.operation(buttonOperation))
        
        // сбрасываем в ноль
        resetLabelText()
    }
    
    @IBAction func clearButtonPressed() {
        calculationHistory.removeAll()
        resetLabelText()
    }
    
    @IBAction func calculateButtonPressed() {
        guard
            let labelText = label.text,
            let labelNumber = numberFormatter.number(from: labelText)?.doubleValue
        else { return }
        
        calculationHistory.append(.number(labelNumber))
        
        do {
            let result = try calculate()
            
            label.text = numberFormatter.string(from: NSNumber(value:result))
        } catch {
            label.text = "Ошибка"
        }
        
        calculationHistory.removeAll()
    }
}
