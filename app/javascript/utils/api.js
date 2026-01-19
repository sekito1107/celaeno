import { FetchRequest } from "@rails/request.js"

export const api = {
  async post(url, body = {}) {
    const request = new FetchRequest("post", url, {
      body: body,
      contentType: "application/json",
      responseKind: "json"
    })
    
    // 成功時も失敗時もFetchRequestがJSONをパースしてくれる
    const response = await request.perform()
    let data = {}
    
    try {
      data = await response.json
    } catch (e) {
      // JSONパースエラー時は空オブジェクトとして扱う
    }

    if (response.ok) {
      return data
    } else {
      throw new Error(data.message || "Request failed")
    }
  },

  async delete(url) {
    const request = new FetchRequest("delete", url, {
      contentType: "application/json",
      responseKind: "json"
    })
    
    const response = await request.perform()
    let data = {}
    
    try {
      data = await response.json
    } catch (e) {
      // JSON parse error
    }

    if (response.ok) {
      return data
    } else {
      throw new Error(data.message || "Request failed")
    }
  }
}
