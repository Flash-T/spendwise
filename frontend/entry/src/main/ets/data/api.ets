/**
 * SpendWise API 服务 - 与后端通信
 */

import http from '@ohos.net.http';
import { UserProfile, Bill, HomeData, SpendingDecision, MonthlyReport } from '../data/models';

const BASE_URL = 'http://121.41.196.62:8000/api';

let accessToken: string = '';

export function setToken(token: string) {
  accessToken = token;
}

export function getToken(): string {
  return accessToken;
}

async function request<T>(method: string, path: string, body?: object): Promise<T> {
  const url = BASE_URL + path;
  const httpRequest = http.createHttp();
  
  return new Promise<T>((resolve, reject) => {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };
    if (accessToken) {
      headers['Authorization'] = `Bearer ${accessToken}`;
    }

    httpRequest.request(url, {
      method: method as http.RequestMethod,
      header: headers,
      extraData: body ? JSON.stringify(body) : undefined,
      connectTimeout: 10000,
      readTimeout: 30000,
    }).then((resp) => {
      const data = JSON.parse(resp.result as string);
      if (resp.responseCode === 200 || resp.responseCode === 201) {
        resolve(data as T);
      } else {
        reject(new Error(data.detail || '请求失败'));
      }
      httpRequest.destroy();
    }).catch((err) => {
      reject(new Error(JSON.stringify(err)));
      httpRequest.destroy();
    });
  });
}

// ====== 用户 ======
export async function register(username: string, email: string, password: string): Promise<{ access_token: string; user: UserProfile }> {
  return request('POST', '/users/register', { username, email, password });
}

export async function login(username: string, password: string): Promise<{ access_token: string; user: UserProfile }> {
  return request('POST', '/users/login', { username, password });
}

export async function getProfile(): Promise<UserProfile> {
  return request('GET', '/users/me');
}

export async function updateProfile(data: Partial<UserProfile>): Promise<UserProfile> {
  return request('PUT', '/users/me', data);
}

// ====== 账单 ======
export async function getBills(page: number = 1, category?: string): Promise<{ total: number; items: Bill[] }> {
  let path = `/bills?page=${page}&page_size=20`;
  if (category) path += `&category=${category}`;
  return request('GET', path);
}

export async function createBill(data: { amount: number; category: string; description: string }): Promise<Bill> {
  return request('POST', '/bills', data);
}

export async function deleteBill(id: number): Promise<void> {
  return request('DELETE', `/bills/${id}`);
}

// ====== AI ======
export async function decideSpending(itemName: string, price: number, category: string, reason: string): Promise<SpendingDecision> {
  return request('POST', '/bills/decide', { item_name: itemName, price, category, reason });
}

export async function getHomeData(): Promise<HomeData> {
  return request('GET', '/advice/daily');
}

export async function getMonthlyReport(year?: number, month?: number): Promise<MonthlyReport> {
  let path = '/bills/report/monthly';
  const params: string[] = [];
  if (year) params.push(`year=${year}`);
  if (month) params.push(`month=${month}`);
  if (params.length) path += '?' + params.join('&');
  return request('GET', path);
}
