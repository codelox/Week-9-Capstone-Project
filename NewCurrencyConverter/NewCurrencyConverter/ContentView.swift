import SwiftUI

struct Conversion: Identifiable {
    let id = UUID()
    let from: String
    let to: String
    let amount: String
    let result: String
}

struct RatesResponse: Codable {
    let rates: [String: Double]
}

struct ContentView: View {
    @State private var amount = ""
    @State private var fromCurrency = "USD"
    @State private var toCurrency = "INR"
    @State private var resultText = ""
    @State private var isLoading = false
    @State private var isDarkMode = false
    @State private var showHistory = false
    @State private var showLiveRate = false
    @State private var history: [Conversion] = []

    let currencies = ["USD", "EUR", "INR", "GBP", "JPY", "CAD", "AUD"]

    var body: some View {
        ZStack {
            (isDarkMode ? Color.black : Color.white).ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Button(action: { showHistory.toggle() }) {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(.blue)
                            .font(.title2)
                    }

                    Spacer()

                    Button(action: {
                        isDarkMode.toggle()
                    }) {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .font(.title2)
                            .foregroundColor(isDarkMode ? .yellow : .blue)
                    }
                }
                .padding(.horizontal)

                Text("Currency Converter")
                    .font(.largeTitle).bold()
                    .foregroundColor(isDarkMode ? .white : .black)

                TextField("Enter amount", text: $amount)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(isDarkMode ? Color(.systemGray5) : Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .foregroundColor(isDarkMode ? .white : .black)

                HStack {
                    Picker("From", selection: $fromCurrency) {
                        ForEach(currencies, id: \.self) {
                            Text("\(flag(for: $0)) \($0)")
                        }
                    }.pickerStyle(MenuPickerStyle())

                    Text("→")
                        .foregroundColor(isDarkMode ? .white : .black)

                    Picker("To", selection: $toCurrency) {
                        ForEach(currencies, id: \.self) {
                            Text("\(flag(for: $0)) \($0)")
                        }
                    }.pickerStyle(MenuPickerStyle())
                }
                .foregroundColor(.blue)

                Button(action: {
                    hideKeyboard()
                    convertCurrency()
                }) {
                    if isLoading {
                        ProgressView()
                            .padding()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Convert")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)

                Button(action: {
                    showLiveRate = true
                }) {
                    Text("📈 Live Rate")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                        .foregroundColor(isDarkMode ? .white : .black)
                        .padding(.horizontal)
                }

                if !resultText.isEmpty {
                    Text(resultText)
                        .font(.title3)
                        .foregroundColor(isDarkMode ? .white : .black)
                        .padding(.top, 10)
                        .transition(.scale.combined(with: .opacity))
                        .onTapGesture {
                            UIPasteboard.general.string = resultText
                        }
                }

                Spacer()
            }
            .padding()
            .onTapGesture {
                hideKeyboard()
            }
            .sheet(isPresented: $showHistory) {
                NavigationView {
                    List(history.indices.reversed(), id: \.self) { index in
                        let item = history[index]
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(item.amount) \(item.from) → \(item.to)")
                                .fontWeight(.medium)
                            Text("Result: \(item.result)")
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                    .navigationBarTitle("Conversion History", displayMode: .inline)
                    .navigationBarItems(leading:
                        Button("Close") {
                            showHistory = false
                        }
                    )
                }
            }
            .sheet(isPresented: $showLiveRate) {
                ExchangeRateView()
                    .preferredColorScheme(isDarkMode ? .dark : .light)
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    func convertCurrency() {
        guard let amountValue = Double(amount), amountValue >= 0 else {
            resultText = "Invalid amount"
            return
        }
        isLoading = true
        resultText = ""

        let urlStr = "https://api.exchangerate-api.com/v4/latest/\(fromCurrency)"
        guard let url = URL(string: urlStr) else {
            resultText = "Invalid URL"
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    resultText = "Network error: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    resultText = "No data"
                }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(RatesResponse.self, from: data)
                if let rate = decoded.rates[toCurrency] {
                    let converted = amountValue * rate
                    let result = "\(String(format: "%.2f", converted)) \(toCurrency)"
                    DispatchQueue.main.async {
                        withAnimation {
                            resultText = result
                        }
                        history.append(Conversion(from: fromCurrency, to: toCurrency, amount: amount, result: result))
                    }
                } else {
                    DispatchQueue.main.async {
                        resultText = "Rate for \(toCurrency) not found"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    resultText = "Decode error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    func flag(for currencyCode: String) -> String {
        let base: UInt32 = 127397
        return currencyCode
            .prefix(2)
            .uppercased()
            .unicodeScalars
            .compactMap { UnicodeScalar(base + $0.value) }
            .map { String($0) }
            .joined()
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
