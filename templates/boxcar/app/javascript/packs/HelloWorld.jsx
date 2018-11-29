import React from 'react';
import ReactDOM from 'react-dom';

import HelloWorld from 'HelloWorld';

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <HelloWorld />,
    document.getElementById('hello-world-root')
  );
});
