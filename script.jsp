let tree;
let currentPath = [];

function appendOutput(content) {
  let pre = document.createElement('pre');
  pre.innerHTML = content;
  document.getElementById('output').appendChild(pre);
}

function getNode(path) {
  let node = tree;
  for (let part of path) {
    node = node[part];
  }
  return node;
}

function renderCurrentLevel() {
  let node = getNode(currentPath);
  let pathStr = currentPath.length > 0 ? '/' + currentPath.join('/') + '/' : '/';
  let content = `Current path: ${pathStr}\n`;

  if (Array.isArray(node)) {
    node.forEach(file => {
      content += `<a href="#" data-type="file" data-file="${file}">${file}</a>\n`;
    });
  } else {
    for (let key in node) {
      content += `<a href="#" data-type="dir" data-dir="${key}">${key}</a>\n`;
    }
  }

  if (currentPath.length > 0) {
    content += `<a href="#" data-type="back">..</a>\n`;
  }

  appendOutput(content);
}

function navigate(dir) {
  currentPath.push(dir);
  renderCurrentLevel();
}

function goBack() {
  currentPath.pop();
  renderCurrentLevel();
}

async function viewFile(file) {
  let basePath = 'docs/';
  let fullPath = basePath + (currentPath.length > 0 ? currentPath.join('/') + '/' : '') + file;
  try {
    const response = await fetch(fullPath);
    if (!response.ok) {
      throw new Error('File not found');
    }
    const content = await response.text();
    appendOutput(`Content of ${fullPath}:\n${content}\n`);
  } catch (error) {
    appendOutput(`Error: ${error.message}\n`);
  }
}

async function init() {
  try {
    const response = await fetch('tree.json');
    if (!response.ok) {
      throw new Error('tree.json not found');
    }
    tree = await response.json();
    renderCurrentLevel();
  } catch (error) {
    appendOutput(`Error: ${error.message}\n`);
  }
}

document.getElementById('output').addEventListener('click', function(e) {
  if (e.target.tagName === 'A') {
    e.preventDefault();
    let type = e.target.getAttribute('data-type');
    if (type === 'dir') {
      let dir = e.target.getAttribute('data-dir');
      navigate(dir);
    } else if (type === 'file') {
      let file = e.target.getAttribute('data-file');
      viewFile(file);
    } else if (type === 'back') {
      goBack();
    }
  }
});

init();
