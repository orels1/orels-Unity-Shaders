using UnityEngine;

namespace ORL.ShaderConditions
{
    /// <summary>
    /// Based on an amazing book https://craftinginterpreters.com/
    /// Thanks to pema.dev for making me ditch my regex jank
    /// You can find said jank here: https://gist.github.com/orels1/8e25df946b8b5d828dc2e5b0efba0af1
    /// </summary>
    public static class Compiler
    {
        public static bool HasError;

        public static void Error(string error)
        {
            HasError = true;
            Debug.LogError(error);
        }

        public static void Error(Token token, string error)
        {
            if (token.Type == TokenType.EOL)
            {
                Error(error);
                return;
            }

            Error($"'{token.Lexeme}' {error}");
        }
    }
}