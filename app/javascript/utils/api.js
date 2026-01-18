import { FetchRequest } from "@rails/request.js"

export const api = {
  async post(url, body = {}) {
    const request = new FetchRequest("post", url, {
      body: JSON.stringify(body),
      responseKind: "json"
    })
    
    const response = await request.perform()
    if (response.ok) {
      return await response.json
    } else {
        const error = await response.json.catch(() => ({}))
        throw new Error(error.message || "Request failed")
    }
  }
}
