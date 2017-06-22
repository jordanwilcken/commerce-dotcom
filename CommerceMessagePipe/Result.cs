using System;

namespace CommerceMessagePipe
{
    internal class Result<T>
    {
        private bool _success;

        private T _value;
        public T Value
        {
            get
            {
                if (!_success)
                    throw new InvalidOperationException();

                return _value;
            }
            private set { _value = value; }
        }

        public string Error { get; private set; }

        public static Result<T> OK(T value) => new Result<T>(value);

        public static Result<T> Fail(string error) => new Result<T> { Error = error };

        private Result(T value)
        {
            Value = value;
            _success = true;
        }

        private Result()
        {
        }

        public void IfSuccess(Action next)
        {
            if (_success)
                next();
        }

        public void IfFailure(Action next)
        {
            if (!_success)
                next();
        }
    }
}
