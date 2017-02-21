import Foundation

fileprivate let defaultSession = URLSession(configuration: URLSessionConfiguration.default)

protocol AuthData {
    var redirectUri: String { get }
    var scope: String { get }
    var clientId: String { get }
    var clientSecret: String { get }
}


struct Feedly {

    let auth: AuthData
    let session: URLSession

    let base = "https://sandbox.feedly.com"
    let signInPath = "/v3/auth/auth"
    let tokenPath = "/v3/auth/token"

    var signInRequest: URLRequest {
        return URLRequest(url: signInURL)
    }

    init(auth: AuthData, session: URLSession = defaultSession) {
        self.auth = auth
        self.session = session
    }

    /// https://developer.feedly.com/v3/auth/#authenticating-a-user-and-obtaining-an-auth-code
    var signInURL: URL {
        var url = URLComponents(string: base)!
        url.path = signInPath
        url.queryItems = signInQueryItems(authInfo: auth)
        return url.url!
    }

    private func signInQueryItems(authInfo: AuthData) -> [URLQueryItem] {
        let response_type = URLQueryItem(name: "response_type", value: "code")
        let client_id = URLQueryItem(name: "client_id", value: authInfo.clientId)
        let redirect_uri = URLQueryItem(name: "redirect_uri", value: authInfo.redirectUri)
        let scope = URLQueryItem(name: "scope", value: authInfo.scope)
        return [response_type, client_id, redirect_uri, scope]
    }

    func requestToken(withCode code: String, completion: @escaping (FeedlyToken) -> Void) {
        let req = tokenRequest(code: code)
        let task = session.dataTask(with: req, completionHandler: tokenResponseHandler(completion))
        task.resume()
    }

    /// https://developer.feedly.com/v3/auth/#exchanging-an-auth-code-for-a-refresh-token-and-an-access-token
    func tokenRequestJSON(code: String) -> Data {
        let dict = [
            "code": code,
            "client_id": auth.clientId,
            "client_secret": auth.clientSecret,
            "redirect_uri": auth.redirectUri,
            "state": "",
            "grant_type": "authorization_code"
        ]
        return try! JSONSerialization // swiftlint:disable:this force_try
            .data(withJSONObject: dict, options: [])
    }

    func tokenRequest(code: String) -> URLRequest {
        guard let url = URL(string: base + tokenPath) else {
           fatalError("Can't build Token Request URL")
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = tokenRequestJSON(code: code)
        return req
    }

    typealias NetworkHandler = (Data?, URLResponse?, Error?) -> Void

    func tokenResponseHandler(_ completion: @escaping ((FeedlyToken) -> Void)) -> NetworkHandler {

        func handleNetworkResponse(data: Data?, response: URLResponse?, err: Error?) {
            guard err == nil else {
                print("\((err as? NSError)?.localizedDescription)")
                return //feel like we need some kind of error completion here
            }

            if  let response = response,
                let urlResponse = response as? HTTPURLResponse {
                print(urlResponse.statusCode)
            }

            guard let data = data else {
                fatalError("False: No data from token Request")
            }

            let tokenResponse = FeedlyToken(data: data)
            completion(tokenResponse)
        }
        return handleNetworkResponse
    }
}

struct FeedlyToken {

    init(data: Data) {
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        print("🏄🏄🏄🏄🏄🏄🏄🏄🏄🏄🏄")
        print(json)
    }

}