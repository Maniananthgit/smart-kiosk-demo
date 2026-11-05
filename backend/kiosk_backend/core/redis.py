import json
from typing import Optional, Any
import redis.asyncio as aioredis
from kiosk_backend.core.config import settings

class RedisService:
    def __init__(self, url: str):
        self.url = url
        self._client: Optional[aioredis.Redis] = None
        self._memory_cache = {}

    async def get_client(self) -> Optional[aioredis.Redis]:
        if self._client is None:
            try:
                self._client = aioredis.from_url(self.url, decode_responses=True, socket_connect_timeout=1)
                await self._client.ping()
            except Exception:
                self._client = None
        return self._client

    async def get(self, key: str) -> Optional[str]:
        client = await self.get_client()
        if client:
            try:
                return await client.get(key)
            except Exception:
                pass
        return self._memory_cache.get(key)

    async def set(self, key: str, value: str, expire: int = 3600) -> bool:
        client = await self.get_client()
        if client:
            try:
                await client.set(key, value, ex=expire)
                return True
            except Exception:
                pass
        self._memory_cache[key] = value
        return True

    async def delete(self, key: str) -> bool:
        client = await self.get_client()
        if client:
            try:
                await client.delete(key)
            except Exception:
                pass
        self._memory_cache.pop(key, None)
        return True

    async def get_json(self, key: str) -> Optional[Any]:
        raw = await self.get(key)
        if raw:
            try:
                return json.loads(raw)
            except Exception:
                return None
        return None

    async def set_json(self, key: str, value: Any, expire: int = 3600) -> bool:
        return await self.set(key, json.dumps(value), expire=expire)

redis_service = RedisService(settings.REDIS_URL)

