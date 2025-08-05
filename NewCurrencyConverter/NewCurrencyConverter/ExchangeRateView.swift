import SwiftUI

struct ExchangeRateView: View {
    let currencies = ["USD", "EUR", "INR", "GBP", "JPY", "CAD", "AUD"]

    @Environment(\.dismiss) private var dismiss
    @State private var allRates: [String: [String: Double]] = [:]
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 16) {
                Text("🌐 All Exchange Rates")
                    .font(.largeTitle.bold())
                    .padding(.top)
                    .multilineTextAlignment(.center)

                if isLoading {
                    ProgressView("Fetching all rates...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text("\(errorMessage)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(currencies, id: \.self) { from in
                                if let rates = allRates[from] {
                                    Section(header:
                                        Text("\(flag(for: from)) \(from)")
                                            .font(.title2.bold())
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal)
                                            .padding(.top)
                                    ) {
                                        ForEach(currencies.filter { $0 != from }, id: \.self) { to in
                                            if let rate = rates[to] {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text("\(flag(for: from)) \(from) → \(flag(for: to)) \(to)")
                                                        .font(.headline)
                                                    Text("1 \(from) = \(String(format: "%.4f", rate)) \(to)")
                                                        .foregroundColor(.blue)
                                                }
                                                .padding()
                                                .background(Color(.secondarySystemBackground))
                                                .cornerRadius(10)
                                                .padding(.horizontal)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.bottom)
                    }
                }

                Spacer()

                Button(action: { dismiss() }) {
                    Text("Back")
                        .padding(.vertical, 12)
                        .padding(.horizontal, 40)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.bottom)
            }
        }
        .onAppear {
            fetchAllRates()
        }
    }

    func fetchAllRates() {
        isLoading = true
        errorMessage = nil
        allRates = [:]

        let group = DispatchGroup()

        for from in currencies {
            group.enter()
            let urlStr = "https://api.exchangerate-api.com/v4/latest/\(from)"
            guard let url = URL(string: urlStr) else {
                group.leave()
                continue
            }

            URLSession.shared.dataTask(with: url) { data, _, error in
                defer { group.leave() }

                if let error = error {
                    DispatchQueue.main.async {
                        errorMessage = "Error fetching \(from): \(error.localizedDescription)"
                    }
                    return
                }

                guard let data = data else { return }

                do {
                    let decoded = try JSONDecoder().decode(RatesResponse.self, from: data)
                    DispatchQueue.main.async {
                        allRates[from] = decoded.rates
                    }
                } catch {
                    DispatchQueue.main.async {
                        errorMessage = "Decode error for \(from): \(error.localizedDescription)"
                    }
                }
            }.resume()
        }

        group.notify(queue: .main) {
            isLoading = false
        }
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
}
