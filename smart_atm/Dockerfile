FROM python:3.12-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source
COPY . .

# Create non-root user
RUN useradd -m appuser && chown -R appuser /app
USER appuser

CMD ["python", "-m", "bot.main"]
