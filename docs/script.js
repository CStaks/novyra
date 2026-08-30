const root = document.documentElement;
const toggle = document.querySelector('.theme-toggle');
const savedTheme = localStorage.getItem('novyra-theme');
const logo = document.querySelector('.brand-logo img');
const favicon = document.querySelector('link[rel="icon"]');

if (savedTheme === 'light' || (!savedTheme && matchMedia('(prefers-color-scheme: light)').matches)) root.classList.add('light');

function updateThemeButton() {
  const light = root.classList.contains('light');
  toggle.textContent = light ? '☾' : '☼';
  toggle.setAttribute('aria-label', light ? 'Switch to dark theme' : 'Switch to light theme');
  if (!logo.hidden) logo.src = light ? 'primary-light-logo.svg' : 'primary-dark-logo.svg';
  if (favicon) favicon.href = light ? 'primary-light-logo.ico' : 'primary-dark-logo.ico';
}

toggle.addEventListener('click', () => {
  root.classList.toggle('light');
  localStorage.setItem('novyra-theme', root.classList.contains('light') ? 'light' : 'dark');
  updateThemeButton();
});

updateThemeButton();
