-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jan 03, 2026 at 11:23 PM
-- Server version: 8.0.44
-- PHP Version: 8.2.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_todo`
--

-- --------------------------------------------------------

--
-- Table structure for table `notes`
--

CREATE TABLE `notes` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `title` varchar(100) NOT NULL,
  `content` text NOT NULL,
  `color` varchar(20) DEFAULT '#fffacd',
  `position_x` int DEFAULT '100',
  `position_y` int DEFAULT '100',
  `is_archived` tinyint(1) DEFAULT '0' COMMENT '0=Active, 1=Archived',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `notes`
--

INSERT INTO `notes` (`id`, `user_id`, `title`, `content`, `color`, `position_x`, `position_y`, `is_archived`, `created_at`, `updated_at`) VALUES
(9, 1, 'Rapat Koordinasi Yayasan', '<p>Tambah Paragraf :</p><ol><li>Content1</li><li>Content2</li><li>Content3\r\n</li></ol><p>Lorem ipsum dolor sit amet consectetur adipiscing elit blandit, convallis molestie scelerisque vehicula maecenas augue conubia nibh, libero dis nunc porttitor feugiat eu habitasse. Sem posuere ut dis sociis ullamcorper ultrices nunc magnis erat aptent hac tristique, porta imperdiet nibh maecenas himenaeos aliquam diam semper volutpat cursus pretium ligula, nostra pulvinar condimentum est senectus nascetur dictum ante phasellus interdum curabitur. Donec pharetra nisi dui suspendisse curabitur placerat ligula nam, cras massa imperdiet natoque hac laoreet mus neque aenean, in mattis purus lobortis mi est egestas. Laoreet sed taciti nisi facilisi urna porta, volutpat torquent hendrerit dui quam imperdiet, tempus cubilia ornare integer morbi.</p>', '#e0ffff', 412, 20, 0, '2026-01-03 10:17:10', '2026-01-03 19:11:55'),
(13, 1, 'Tester Note', '<p>Lorem ipsum dolor sit amet consectetur adipiscing elit blandit, convallis molestie scelerisque vehicula maecenas augue conubia nibh, libero dis nunc porttitor feugiat eu habitasse. Sem posuere ut dis sociis ullamcorper ultrices nunc magnis erat aptent hac tristique, porta imperdiet nibh maecenas himenaeos aliquam diam semper volutpat cursus pretium ligula, nostra pulvinar condimentum est senectus nascetur dictum ante phasellus interdum curabitur. Donec pharetra nisi dui suspendisse curabitur placerat ligula nam, cras massa imperdiet natoque hac laoreet mus neque aenean, in mattis purus lobortis mi est egestas. Laoreet sed taciti nisi facilisi urna porta, volutpat torquent hendrerit dui quam imperdiet, tempus cubilia ornare integer morbi. Asdf</p>', '#d6d8db', 1022, 222, 1, '2026-01-03 10:46:02', '2026-01-03 16:15:06'),
(14, 1, 'Tester Note-1', '<p>Lorem ipsum dolor sit amet consectetur adipiscing elit blandit, convallis molestie scelerisque vehicula maecenas augue conubia nibh, libero dis nunc porttitor feugiat eu habitasse. Sem posuere ut dis sociis ullamcorper ultrices nunc magnis erat aptent hac tristique, porta imperdiet nibh maecenas himenaeos aliquam diam semper volutpat cursus pretium ligula, nostra pulvinar condimentum est senectus nascetur dictum ante phasellus interdum curabitur. Donec pharetra nisi dui suspendisse curabitur placerat ligula nam, cras massa imperdiet natoque hac laoreet mus neque aenean, in mattis purus lobortis mi est egestas. Laoreet sed taciti nisi facilisi urna porta, volutpat torquent hendrerit dui quam imperdiet, tempus cubilia ornare integer morbi.</p><p><br></p><p><span>Lorem ipsum dolor sit amet consectetur adipiscing elit nostra vulputate, facilisis imperdiet varius arcu fringilla massa pharetra. Euismod taciti commodo lobortis aptent dictumst in sociis cum dis, viverra dui montes torquent justo mattis eros. Nascetur ornare mauris blandit varius mus eleifend platea fringilla, urna cum lectus sociis duis malesuada semper sodales nam, nulla turpis ridiculus fusce eget massa inceptos.</span></p><p><br></p><p><span>Lorem ipsum dolor sit amet consectetur adipiscing elit nostra vulputate, facilisis imperdiet varius arcu fringilla massa pharetra. Euismod taciti commodo lobortis aptent dictumst in sociis cum dis, viverra dui montes torquent justo mattis eros. Nascetur ornare mauris blandit varius mus eleifend platea fringilla, urna cum lectus sociis duis malesuada semper sodales nam, nulla turpis ridiculus fusce eget massa inceptos.</span></p>', '#cce5ff', 548, 20, 0, '2026-01-03 10:47:14', '2026-01-03 19:11:50'),
(15, 1, 'Tambah Notes', '<p>Tambah Notes : </p><ol><li>Test1</li><li>Test2</li><li>Test3</li></ol><p>Lorem ipsum dolor sit amet consectetur adipiscing elit blandit, convallis molestie scelerisque vehicula maecenas augue conubia nibh, libero dis nunc porttitor feugiat eu habitasse. Sem posuere ut dis sociis ullamcorper ultrices nunc magnis erat aptent hac tristique, porta imperdiet nibh maecenas himenaeos aliquam diam semper volutpat cursus pretium ligula, nostra pulvinar condimentum est senectus nascetur dictum ante phasellus interdum curabitur. Donec pharetra nisi dui suspendisse curabitur placerat ligula nam, cras massa imperdiet natoque hac laoreet mus neque aenean, in mattis purus lobortis mi est egestas. Laoreet sed taciti nisi facilisi urna porta, volutpat torquent hendrerit dui quam imperdiet, tempus cubilia ornare integer morbi.</p>', '#d8bfd8', 261, 20, 0, '2026-01-03 10:49:06', '2026-01-03 19:11:35'),
(17, 1, 'TTTT', '<p><span>Lorem ipsum dolor sit amet consectetur adipiscing elit dapibus cras, habitant gravida nostra nec ac sapien hendrerit interdum, molestie sem cubilia turpis elementum ad eget dictum. Magnis porttitor tempor habitant dignissim condimentum bibendum, at torquent consequat tempus. Curae eget molestie vitae ultrices himenaeos vulputate, tincidunt praesent dui vestibulum litora mollis feugiat, ullamcorper arcu fringilla lacus bibendum. Leo feugiat faucibus mi congue pretium suscipit mauris facilisis laoreet, rhoncus fusce tincidunt orci morbi non massa pharetra.</span></p>', '#fff3cd', 20, 222, 0, '2026-01-03 17:12:34', '2026-01-03 17:12:54');

-- --------------------------------------------------------

--
-- Table structure for table `todos`
--

CREATE TABLE `todos` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `task` varchar(255) NOT NULL,
  `description` text,
  `status` enum('pending','in_progress','completed','archived') NOT NULL DEFAULT 'pending',
  `priority` enum('low','medium','high') DEFAULT 'medium',
  `due_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `todos`
--

INSERT INTO `todos` (`id`, `user_id`, `task`, `description`, `status`, `priority`, `due_date`, `created_at`, `updated_at`) VALUES
(1, 1, 'Beli Telur', 'Beli Telur di Kedai', 'archived', 'medium', '2026-01-04', '2026-01-03 07:47:00', '2026-01-03 09:24:41'),
(2, 1, 'Cuci Piring', 'Cuci Piring', 'pending', 'low', '2026-01-05', '2026-01-03 07:51:34', '2026-01-03 13:13:13'),
(4, 1, 'Testing Todos', 'teste', 'archived', 'medium', '2026-01-05', '2026-01-03 08:50:19', '2026-01-03 17:06:52'),
(6, 2, 'Test', 'Tester', 'pending', 'medium', '2026-01-11', '2026-01-03 09:58:37', '2026-01-03 19:31:18'),
(7, 1, 'Tester', 'Tester Lagi', 'pending', 'high', '2026-01-06', '2026-01-03 10:12:01', '2026-01-03 11:20:47'),
(8, 1, 'Tester2', 'Tester2 Lagi', 'pending', 'high', '2026-01-08', '2026-01-03 10:18:17', '2026-01-03 10:29:48'),
(9, 1, 'Testing lagi', 'Lagi Lagi testing', 'pending', 'high', '2026-01-06', '2026-01-03 10:25:53', '2026-01-03 11:20:46'),
(10, 1, 'Testing10', 'Lorem ipsum dolor sit amet consectetur adipiscing elit blandit, convallis molestie scelerisque vehicula maecenas augue conubia nibh, libero dis nunc porttitor feugiat eu habitasse.', 'pending', 'low', '2026-01-12', '2026-01-03 11:21:30', '2026-01-03 11:23:57'),
(11, 1, 'Weleh1', 'Weleh lagi', 'pending', 'medium', NULL, '2026-01-03 13:17:42', '2026-01-03 13:17:42'),
(12, 1, 'Weleh 2', 'Weleh Lagi', 'pending', 'high', '2026-01-07', '2026-01-03 13:17:58', '2026-01-03 13:23:18'),
(13, 1, 'Weleh3', 'Weleh 3', 'pending', 'low', NULL, '2026-01-03 13:18:41', '2026-01-03 13:18:41'),
(14, 1, 'TTTT', 'Lorem ipsum dolor sit amet consectetur adipiscing elit class, eleifend massa lacinia dis consequat habitasse mi sodales, in tellus auctor maecenas est iaculis eu. Quam augue luctus eu condimentum ut ligula urna curae, commodo felis neque taciti scelerisque dapibus mollis aliquet, venenatis feugiat justo tincidunt facilisis euismod dictum. Eu hendrerit varius blandit elementum suscipit convallis morbi, tristique himenaeos est aptent in litora placerat laoreet, risus arcu cursus justo luctus pulvinar. Ornare malesuada rutrum sagittis nunc aptent fermentum ante, praesent viverra per magna tincidunt massa purus, habitant ullamcorper vivamus litora posuere nisi. Morbi ridiculus neque magnis scelerisque sagittis mus tempus purus posuere praesent, condimentum malesuada vulputate libero imperdiet ut sed enim suscipit, bibendum turpis risus taciti conubia rhoncus quam habitant cum. Erat donec gravida molestie habitasse neque aenean posuere, lobortis bibendum orci sociis suscipit etiam. Sed ad v', 'pending', 'medium', '2026-01-14', '2026-01-03 17:09:35', '2026-01-03 17:10:11');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','user') DEFAULT 'user',
  `is_approved` tinyint(1) DEFAULT '1',
  `is_aktif` tinyint(1) NOT NULL DEFAULT '1',
  `approved_by` int DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `email`, `password`, `role`, `is_approved`, `is_aktif`, `approved_by`, `approved_at`, `created_at`) VALUES
(1, 'admin', 'admin@example.com', '$2y$10$8Nq/3Kiz7jDWpz4HDhdvJ.wb2YZHL3xypcAnJEIA0qn/zzJRvyBLm', 'admin', 1, 1, 1, '2026-01-03 11:49:22', '2026-01-03 07:31:28'),
(2, 'user', 'user@example.com', '$2y$10$SkbKzeFswaKUyBA78IhKk.7ztAhUJX/X4rti7PJNmsqCIIP1DkIJS', 'user', 1, 1, 1, '2026-01-03 12:10:00', '2026-01-03 07:31:28'),
(4, 'Naufal', 'nufal@mail.com', '$2y$10$gXhiARVZQi8neuUYdh32suINjpN3pzVNBw7H1t//YyVM2rQa5r/YG', 'user', 1, 1, 1, '2026-01-03 12:14:11', '2026-01-03 12:10:51'),
(5, 'Fakhriza', 'fakhriza@mail.com', '$2y$10$ni5ColGEc.REoDXGnHFlnu7lYzD0O7P/dQZJLx.ZKcZL529DhE50.', 'admin', 1, 1, 1, '2026-01-03 12:23:26', '2026-01-03 12:20:29'),
(6, 'Andre', 'andre@mail.com', '$2y$10$mU9/odvSCXUPDHg1/h3n9.F0O9Gfx/A1/KlSStEHtPsMyfST8GlJe', 'user', 1, 1, NULL, NULL, '2026-01-03 13:38:08'),
(11, 'Susan', 'susan@mail.com', '$2y$10$o.kEm4u7xoyVlf7gIt3acOO94kuyeA2aMrFu7Evsef/ouevTl3gkq', 'user', 1, 1, 1, '2026-01-03 13:56:15', '2026-01-03 13:54:52'),
(12, 'Indra', 'indra@mail.com', '$2y$10$HWrATbzgnVWZesR74gBPbOOMiZx0bA32D4cbJ6PjEky8VPt0rXPEm', 'user', 1, 1, 1, '2026-01-03 13:56:19', '2026-01-03 13:55:09'),
(13, 'Santi', 'santi@mail.com', '$2y$10$k9UcWuCs5RGAp1lmEEs7OuWhc/NDjwX2S.lfjH//oQVJcub4jdStu', 'user', 1, 1, 1, '2026-01-03 13:56:23', '2026-01-03 13:55:43'),
(14, 'Rina', 'rina@mail.com', '$2y$10$XEj7X84.94uHLvMYz6vdHe6tfvikbqhhMl.OxWEsL2s/s0cq1YETG', 'user', 1, 1, NULL, NULL, '2026-01-03 13:57:06'),
(18, 'Randi', 'randi@mail.com', '$2y$10$pLSQ2MQwUpP8OGvC3Yx.muvCxP41UiJ3VOBsoQOZA.I1l6GiDNtb.', 'user', 1, 0, NULL, NULL, '2026-01-03 14:01:18'),
(20, 'jane_admin', 'jane@example.com', '$2y$10$rBINOeyb1A8eQXO6LpbHueuwWXEw6Tqd0Y.pxX9b6LpEU8hC.FFPW', 'admin', 1, 1, NULL, NULL, '2026-01-03 15:49:49'),
(22, 'Agus', 'agus@mail.com', '$2y$10$coGyxNrci8oGl/0YhpkKGOhj3pW7.PPeGO2V6TTz1Uk9CYJcdXQm.', 'user', 1, 1, NULL, NULL, '2026-01-03 17:02:50'),
(25, 'inactive_user', 'inactive@example.com', '$2y$10$AgMmQEdPLaHlMX/Emd0Tgu/VqfxbcfEtO22vBeMvrGpGucqOFexSi', 'user', 1, 0, NULL, NULL, '2026-01-03 17:03:46');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `notes`
--
ALTER TABLE `notes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `todos`
--
ALTER TABLE `todos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_todos_user_status` (`user_id`,`status`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `fk_approved_by` (`approved_by`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `notes`
--
ALTER TABLE `notes`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `todos`
--
ALTER TABLE `todos`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `notes`
--
ALTER TABLE `notes`
  ADD CONSTRAINT `notes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `todos`
--
ALTER TABLE `todos`
  ADD CONSTRAINT `todos_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_approved_by` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
