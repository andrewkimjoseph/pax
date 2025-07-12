// Escape Markdown special characters for Telegram
export function escapeMarkdown(text: string): string {
  // If the text looks like an email address, handle it specially
  if (text.includes('@') && text.includes('.')) {
    // For email addresses, only escape characters that are not part of valid email format
    return text.replace(/([_*\[\]()~`>#+\-=|{}!])/g, '\\$1');
  }
  
  // If the text looks like a URL (starts with http/https), handle it specially
  if (text.startsWith('http://') || text.startsWith('https://')) {
    // For URLs, only escape characters that are not part of valid URL format
    // Don't escape equals signs as they're used for query parameters
    return text.replace(/([_*\[\]()~`>#+{}!])/g, '\\$1');
  }
  
  // For regular text, escape only characters that actually affect Markdown formatting
  // Don't escape parentheses as they're safe in regular text
  return text.replace(/([_*\[\]~`>#+\-=|{}.!])/g, '\\$1');
}
  